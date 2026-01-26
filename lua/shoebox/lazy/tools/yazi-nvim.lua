local vim = vim
return {
	{
		"mikavilpas/yazi.nvim",
		dependencies = {
			"s1n7ax/nvim-window-picker",
		},
		keys = {
			{
				"<leader>-",
				"<cmd>Yazi<cr>",
				desc = "Open yazi at the current file",
			},
			{
				"<leader>-",
				"<cmd>Yazi<cr>",
				desc = "Open yazi at the current file",
			},
			{
				"<leader>cw",
				"<cmd>Yazi cwd<cr>",
				desc = "Open the file manager in nvim's working directory",
			},
			{
				"<c-up>",
				"<cmd>Yazi toggle<cr>",
				desc = "Resume the last yazi session",
			},
		},
		opts = {
			open_for_directories = false,

			open_file_function = function(chosen_file, config, state)
				local window_id = require("window-picker").pick_window()
				vim.api.nvim_set_current_win(window_id)
				vim.cmd("e " .. chosen_file)
			end,
			keymaps = {
				show_help = "<f1>",
			},
		},
	},
}
