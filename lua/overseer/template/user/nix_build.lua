return {
	name = "Nix build",
	builder = function()
		local file = vim.fn.expand("%:p")
		local cmd = { file }
		if vim.bo.filetype == "go" then
			cmd = { "nix", "build" }
		end

		return {
			cmd = cmd,
			components = {
				{ "on_output_quickfix", set_diagnostics = true },
				"on_result_diagnostics",
				{ "on_result_notify", infer_status_from_diagnostics = true, on_change = false },
				"default",
			},
		}
	end,
	condition = {
		filetype = { "go" },
	},
}
