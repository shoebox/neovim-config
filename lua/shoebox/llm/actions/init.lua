local M = {}

M.CodeAction = require("shoebox.llm.actions.codeaction")
M.ReturnSurroundedCode = require("shoebox.llm.actions.returnsurroundedcode")
M.WithLspInfos = require("shoebox.llm.actions.withlspinfos")

return M
