local actions = require("shoebox.llm.actions")
local constants = require("shoebox.llm.constants")
local roles = require("shoebox.llm.roles")

return {
  strategy = "chat",
  description = "Add missing documentation to the code",
  opts = {
    auto_submit = true,
    modes = { "n", "v" },
  },
  prompts = {
    roles.Developer,
    {
      role = constants.USER_ROLE,
      content = [[
      Analyze the following Go code and review its documentation.
      For each exported type, function, method, or package-level
      variable/constant:

- Add missing doc comments following the programming language best-practices (e.g. for Go: https://go.dev/doc/effective_go)
- Correct any incorrect, outdated, or misleading existing documentation.
- Only document exported identifiers, unless an unexported item has complex or non-obvious logic.
- Do not add comments to struct fields, local variables, or simple unexported identifiers.
- Avoid redundant parameter/return sections unless needed for clarity.
- Ensure all comments are clear, concise, and follow the programming language best practices.
- Do not modify the code structure or logic, focus only on documentation.]],
      opts = {
        visible = true,
      },
    },
    actions.ReturnSurroundedCode,
    actions.WithLspInfos,
    actions.CodeAction.CodeAction("here is the target code"),
    {
      role = constants.USER_ROLE,
      content = [[ Thanks, not let's revise the documentation you provided to
      ensure it follows best-practices and standard for the programming language.]],
      opts = {
        visible = true,
      },
    },
  },
}
