local constants = require("shoebox.llm.constants")

return {
  role = constants.SYSTEM_ROLE,
  content = function()
    return "#{lsp}"
  end,
}
