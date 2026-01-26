local constants = require("shoebox.llm.constants")

return {
  role = constants.SYSTEM_ROLE,
  content = function(context)
    return "Return any code snippet surrounded by triple backticks "
      .. "and use the language name of the filetype, example: "
      .. "```"
      .. context.filetype
      .. "\n"
      .. "```"
  end,
}
