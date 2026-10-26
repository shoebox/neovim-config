return {
	desc = "Redirects stdout to notifications",
	constructor = function(params)
		return {
			on_output_lines = function(self, task, lines)
				for _, line in ipairs(lines) do
					vim.notify(string.format("[%s] %s", task.name, line), vim.log.levels.INFO)
				end
			end,
		}
	end,
}
