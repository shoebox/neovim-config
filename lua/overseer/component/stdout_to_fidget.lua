return {
	desc = "Redirects stdout to Fidget",
	constructor = function(params)
		local fidget = require("fidget")
		-- You may optionally define any of the methods below
		return {
			on_output_lines = function(self, task, lines)
				groupName = "Overseer.nvim"
				for _, line in ipairs(lines) do
					fidget.notify(line, vim.log.levels.INFO, { group = groupName, annotate = task.name })
				end
			end,
		}
	end,
}
