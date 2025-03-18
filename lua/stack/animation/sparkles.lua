local M = {}

-- TODO:  <13-03-25, ss> -- fix location of spawan, should be on new window or fullscreen
function M.add_sparkles()
	local symbols = { "★", "✦", "✧", "✯", "✨", "❋" }
	local colors = { "#FFD700", "#FF69B4", "#00FFFF", "#39FF14" }

	for _ = 1, 8 do
		-- local win = vim.api.nvim_get_current_win()
		local buf = vim.api.nvim_create_buf(false, true)
		local width, height = 1, 1

		local c_win = vim.api.nvim_get_current_win()
		local win_pos = vim.api.nvim_win_get_position(c_win)
		local c_row = win_pos[1]
		local c_col = win_pos[2]

		local win_width = vim.api.nvim_win_get_width(c_win)
		local win_height = vim.api.nvim_win_get_height(c_win)

		local row = math.random(c_row, win_height)
		local col = math.random(c_col, win_width)

		local sparkle_win = vim.api.nvim_open_win(buf, false, {
			relative = "editor",
			row = row,
			col = col,
			width = width,
			height = height,
			style = "minimal",
		})

		-- Set sparkle text and color
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, { symbols[math.random(#symbols)] })
		vim.api.nvim_set_hl(0, "SparkleHL", { fg = colors[math.random(#colors)] })

		if vim.api.nvim_win_is_valid(sparkle_win) then
			vim.api.nvim_set_option_value("winhl", "Normal:SparkleHL", { win = sparkle_win })
		end

		-- Close window
		vim.defer_fn(function()
			if vim.api.nvim_win_is_valid(sparkle_win) then
				vim.api.nvim_win_close(sparkle_win, true)
			end
		end, 1000)
	end
end

return M
