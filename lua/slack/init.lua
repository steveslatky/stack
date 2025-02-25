local M = {}
local w = require("slack.win")

function M.setup(opts)
	require("slack.config").setup(opts)

	vim.api.nvim_create_user_command("Slack", function()
		w.create_window()
	end, {})
end

return M
