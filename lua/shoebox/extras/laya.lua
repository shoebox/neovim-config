local M = {}

local defaults = {
  endpoint = vim.env.LAYA_URL or "http://127.0.0.1:8770/api/predict",
  timeout = 2,
  debug = false,
  -- Model routing follows Laya's top choice by default; raise this for safer
  -- escalation when a wrong model choice is costly.
  threshold = 0,
  fallback_model = "auto",
  models_by_provider = {},
  models = {
    advanced = vim.env.LAYA_MODEL_ADVANCED,
    quick_edit = vim.env.LAYA_MODEL_QUICK_EDIT,
    implementation = vim.env.LAYA_MODEL_IMPLEMENTATION,
    debugging = vim.env.LAYA_MODEL_DEBUGGING,
    architecture = vim.env.LAYA_MODEL_ARCHITECTURE,
    review = vim.env.LAYA_MODEL_REVIEW,
  },
}

local config = vim.deepcopy(defaults)

function M.pick_route(answer, threshold)
  if type(answer) ~= "table" or type(answer.choice) ~= "string" then
    return nil
  end
  local confidence = answer.answer_confidence or answer.confidence
  if type(confidence) ~= "number" or confidence < (threshold or 0) then
    return nil
  end
  return answer.choice
end

local function model_label(model)
  if type(model) == "table" then
    local parts = {}
    if model.reasoning then
      parts[#parts + 1] = "reasoning=" .. model.reasoning
    end
    if model.fast ~= nil then
      parts[#parts + 1] = "fast=" .. tostring(model.fast)
    end
    return #parts > 0 and table.concat(parts, ",") or vim.inspect(model)
  end
  return model
end

local function available_models_label(options)
  local models = options and options.model and options.model.options
  if not models and options and options.legacy_agent_models then
    models = options.legacy_agent_models._models
  end
  if not models or #models == 0 then
    return "(none advertised)"
  end

  local labels = {}
  for _, model in ipairs(models) do
    labels[#labels + 1] =
      string.format("%s [%s]", model.name or "?", model.value or model.modelId)
  end
  return table.concat(labels, " | ")
end

function M.format_recommendation(route, confidence, model_id, accepted)
  model_id = model_label(model_id)
  if not route then
    return "Laya recommendation unavailable" .. (model_id and (" -> " .. model_id) or "")
  end
  local percent = math.floor((confidence or 0) * 100 + 0.5)
  return string.format(
    accepted == false and "Laya uncertain: %s (%d%%)%s"
      or "Laya recommends %s (%d%%)%s",
    route,
    percent,
    model_id and (" -> " .. model_id) or " (no model mapping)"
  )
end

function M.choose_model(route, models, fallback, provider, models_by_provider)
  local provider_models = provider and models_by_provider and models_by_provider[provider]
  if provider_models then
    models = vim.tbl_extend("force", models, provider_models)
  end
  if route == "architecture" or route == "review" then
    return models[route] or models.advanced or fallback
  end
  return (route and models[route]) or fallback
end

local function normalize_model_name(value)
  return tostring(value):lower():gsub("[^%w]", "")
end

local function metadata_matches(value, selector)
  for key, expected in pairs(selector) do
    if key ~= "name" then
      local keys = { key }
      if key == "reasoning" then
        keys = { "reasoning", "reasoning_effort", "effort" }
      end
      local actual
      for _, metadata_key in ipairs(keys) do
        actual = tostring(value):match(metadata_key .. "=([^,%]]+)")
        if actual then
          break
        end
      end
      if actual ~= tostring(expected) then
        return false
      end
    end
  end
  return true
end

local function option_matches(option, requested)
  if type(requested) == "string" then
    if requested == "auto" then
      local value = tostring(option.value or ""):lower()
      local name = normalize_model_name(option.name or "")
      return value:match("^auto") ~= nil
        or name:find("auto", 1, true) ~= nil
        or value:find("optimize_for=balanced", 1, true) ~= nil
    end
    return option.value == requested
      or (option.name and normalize_model_name(option.name) == normalize_model_name(requested))
  end
  if type(requested) ~= "table" then
    return false
  end
  return (not requested.name or (option.name and
    normalize_model_name(option.name) == normalize_model_name(requested.name)))
    and metadata_matches(option.value, requested)
end

function M.resolve_model_id(options, requested)
  if not options or not requested then
    return nil
  end

  if options.model then
    for _, option in ipairs(options.model.options or {}) do
      if option_matches(option, requested) then
        return option.value
      end
    end
    return nil
  end

  if options.legacy_agent_models then
    local model = options.legacy_agent_models:get_model(requested)
    return model and model.modelId or nil
  end

  return nil
end

local function log_message(message, highlight)
  vim.api.nvim_echo({ { message, highlight or "None" } }, true, {})
end

local function classify(prompt, callback)
  local body = vim.json.encode({
    state = prompt,
    questions = {
      route = {
        type = "choice",
        instructions = "Which kind of coding request is this?",
        criteria = {
          trivial = "one-step answer, syntax lookup, obvious command, or typo with no repository analysis",
          bug_fix = "investigating an unknown issue or fixing a known bug",
          feature = "adding new functionality to existing code",
          refactoring = "improving code structure without changing behavior",
          testing = "writing or debugging tests",
          documentation = "creating or updating documentation",
          configuration = "setting up tools, configuration, or environments",
          ops_deployment = "CI/CD, deployment, infrastructure, or operations",
          styling = "visual design, CSS, layout, or presentation work",
          explanation = "understanding or explaining existing code",
          performance = "optimizing code for speed or efficiency",
        },
      },
    },
  })
  local path = vim.fn.tempname()
  vim.fn.writefile({ body }, path)

  vim.system({
    "curl",
    "-fsS",
    "--max-time",
    tostring(config.timeout),
    "-H",
    "Content-Type: application/json",
    "--data-binary",
    "@" .. path,
    config.endpoint,
  }, {}, function(result)
    vim.schedule(function()
      vim.fn.delete(path)
    end)
    if result.code ~= 0 then
      callback(nil, result.stderr ~= "" and vim.trim(result.stderr) or "Laya unavailable")
      return
    end

    local ok, decoded = pcall(vim.json.decode, result.stdout or "")
    if not ok or type(decoded) ~= "table" then
      callback(nil, "Invalid Laya response")
      return
    end
    callback(decoded.answers and decoded.answers.route)
  end)
end

local function submit(session, prompt)
  session:_handle_input_submit(prompt)
end

local function route_and_submit(prompt)
  local session = require("agentic.session_registry").current()
  if not session then
    return
  end

  classify(prompt, function(answer, err)
    vim.schedule(function()
      local route = M.pick_route(answer, config.threshold)
      local model_id = M.choose_model(
        route,
        config.models,
        config.fallback_model,
        session.provider_name,
        config.models_by_provider
      )
      local recommended_route = answer and answer.choice
      local confidence = answer and (answer.answer_confidence or answer.confidence)
      local options = session.config_options
      local requested_model = model_id
      if config.debug then
        log_message(string.format(
          "Laya selection: provider=%s route=%s confidence=%d%% target=%s",
          session.provider_name or "?",
          recommended_route or "unavailable",
          math.floor((confidence or 0) * 100 + 0.5),
          model_label(requested_model) or "none"
        ), "Directory")
        log_message("Laya available models: " .. available_models_label(options), "Comment")
      end
      model_id = M.resolve_model_id(options, requested_model)
      local used_fallback = false
      if not model_id and requested_model ~= config.fallback_model then
        model_id = M.resolve_model_id(options, config.fallback_model)
        used_fallback = model_id ~= nil
      end
      if config.debug then
        log_message(
          "Laya resolved model: "
            .. (model_id or "(no match; keeping current model)")
            .. (used_fallback and " (fallback)" or ""),
          model_id and "MoreMsg" or "WarningMsg"
        )
      end

      log_message(
        M.format_recommendation(
          recommended_route,
          confidence,
          requested_model,
          route ~= nil
        )
      )

      if err then
        vim.notify("Laya: " .. err .. "; using current model", vim.log.levels.DEBUG)
      elseif not model_id then
        vim.notify(
          string.format(
            "Laya: %s (%d%%); using current model",
            route or "uncertain",
            math.floor((confidence or 0) * 100 + 0.5)
          ),
          vim.log.levels.INFO
        )
      end

      if not model_id then
        submit(session, prompt)
        return
      end

      if
        not options
        or not options.handle_model_change
        or not model_id
      then
        if requested_model and not model_id then
          log_message(
            "Laya model unavailable: " .. requested_model .. "; using current model",
            "WarningMsg"
          )
        end
        submit(session, prompt)
        return
      end

      local is_legacy = options.model == nil
      options:handle_model_change(model_id, is_legacy, function()
        vim.schedule(function()
          submit(session, prompt)
        end)
      end)
    end)
  end)
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
end

function M.init()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "AgenticInput",
    callback = function(args)
      vim.defer_fn(function()
        if not vim.api.nvim_buf_is_valid(args.buf) then
          return
        end

        local function route_submit()
          vim.cmd("stopinsert")
          local prompt = table.concat(vim.api.nvim_buf_get_lines(args.buf, 0, -1, false), "\n")
            :match("^%s*(.-)%s*$")
          if prompt and prompt:match("%S") then
            vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, {})
            route_and_submit(prompt)
          end
        end

        vim.keymap.set({ "i", "n", "v" }, "<C-s>", route_submit, {
          buffer = args.buf,
          desc = "Agentic: route prompt with Laya",
        })
      end, 50)
    end,
  })
end

return M
