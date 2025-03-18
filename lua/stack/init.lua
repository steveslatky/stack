local M = {}
local w = require("stack.win")
Log = require("stack.log")

function M.setup(opts)
	require("stack.config").setup(opts)
	Log.setup()

	vim.api.nvim_create_user_command("StackBottom", function()
		w.create_window(w.BottomPanel)
	end, {})
	vim.api.nvim_create_user_command("StackSide", function()
		w.create_window(w.SidePanel)
	end, {})
	vim.api.nvim_create_user_command("StackNo", function()
		w.create_window(w.Notification)
	end, {})

	vim.api.nvim_create_user_command("StackModal", function()
		w.create_window(w.CenteredModal)
	end, {})

	vim.api.nvim_create_user_command("StackTop", function()
		w.create_window(w.TopPanel)
	end, {})

	vim.api.nvim_create_user_command("StackLog", function()
		Log.open_log()
	end, {})
end

return M
