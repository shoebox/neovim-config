local M = {}
local constants = require("shoebox.llm.constants")

M.CodeAction = function(txt)
  return {
    role = constants.USER_ROLE,
    content = function(context)
      local code
      if context.is_normal then
        return "#{buffer}"
      else
        local start_line = context.start_line or 1
        local end_line = context.end_line or vim.api.nvim_buf_line_count(context.bufnr)
        code = require("codecompanion.helpers.actions").get_code(start_line, end_line)
      end
      return string.format(
        [[%s
Please for this code from buffer #{buffer} with filetype

```%s
%s
```
]],
        txt,
        context.bufnr,
        context.filetype,
        code
      )
    end,
    opts = {
      contains_code = true,
      visible = true,
    },
  }
end

M.AuditGeneratedCode = function()
  return {
    role = constants.U,
    content = [[Great. Now let's consider your code. I'd like you to check it
carefully for correctness, style, and efficiency, and give constructive
criticism for how to improve it.]],
    opts = {
      contains_code = true,
    },
  }
end

M.Revise = function()
  return {
    role = constants.SYSTEM_ROLE,
    content = [[ Thanks. Now let's revise the code based on the feedback,
without additional explanations]],
    opts = {
      contains_code = true,
    },
  }
end

return M
