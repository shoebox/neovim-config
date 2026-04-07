-- Spec Kit Plugin for Neovim
-- Displays specs, shows state, and allows running phases individually

local function make_keys()
  local speckit = function()
    return require("speckit")
  end
  local picker = function()
    return require("speckit.picker")
  end

  return {
    {
      "<leader>sk",
      function()
        picker().pick_spec()
      end,
      desc = "Spec Kit - Pick a spec",
    },
    {
      "<leader>sc",
      function()
        speckit().run_phase("constitution")
      end,
      desc = "Spec Kit - Run constitution",
    },
    {
      "<leader>ss",
      function()
        speckit().run_phase("specify")
      end,
      desc = "Spec Kit - Run specify",
    },
    {
      "<leader>sP",
      function()
        speckit().run_phase("plan")
      end,
      desc = "Spec Kit - Run plan",
    },
    {
      "<leader>st",
      function()
        speckit().run_phase("tasks")
      end,
      desc = "Spec Kit - Run tasks",
    },
    {
      "<leader>si",
      function()
        picker().pick_task()
      end,
      desc = "Spec Kit - Pick task to implement",
    },
    {
      "<leader>so",
      function()
        picker().pick_overview()
      end,
      desc = "Spec Kit - Overview",
    },
  }
end

return {
  {
    dir = "~/Desktop/shoebox/speckit.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    keys = make_keys(),
    cmd = {
      "SpeckitPick",
      "SpeckitConstitution",
      "SpeckitSpecify",
      "SpeckitClarify",
      "SpeckitPlan",
      "SpeckitTasks",
      "SpeckitAnalyze",
      "SpeckitChecklist",
      "SpeckitImplement",
      "SpeckitOverview",
      "SpeckitWorkflow",
      "SpeckitState",
      "SpeckitSuggest",
      "SpeckitTerminals",
    },
    opts = {
      terminal = {
        agent_cmd = "auggie -w %s %s",
        backend = "agentic",
      },
    },
  },
}
