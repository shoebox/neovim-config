local constants = require("shoebox.llm.constants")
local roles = require("shoebox.llm.roles")
return {
  strategy = "chat",
  description = "Review the code and provide feedback",
  opts = {
    index = 11,
    is_slash_cmd = false,
    auto_submit = true,
    alias = "write_article",
  },
  prompts = {
    roles.Techwriter,
    {
      role = constants.USER_ROLE,
      content = [[ I will give you a subject and you will come up with
  an engaging article on how to do those basic steps. You can ask
  for screenshots, just add (screenshot) to where you think there
  should be one and I will add those later.]],
    },
  },
}
