---@class Stack.Logger.Highlights
local M = {}

local hl = require("stack.win.hl")

-- TODO:  <17-03-25, ss> -- Need to check if they work with more colorschemes/are there defaults that work to match cs?
local log_highlight_groups = {
	StackLogTimestamp = { fg = "#61AFEF" },
	StackLogDEBUG = { fg = "#98C379" },
	StackLogINFO = { fg = "#61AFEF" },
	StackLogWARN = { fg = "#E5C07B" },
	StackLogERROR = { fg = "#E06C75" },
	StackLogContent = { fg = "#C678DD" },
}
--- Apply highlighting to log buffer
---@param buf number Buffer handle
function M.highlight_log_buffer(buf)
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local highlights = {}
	hl.setup_highlight_groups(log_highlight_groups)

	local in_content_block = false
	local content_depth = 0
	for i, line in ipairs(lines) do
		local line_idx = i - 1
		if in_content_block then
			table.insert(highlights, hl.region(line_idx, 0, #line, "StackLogContent"))
			local open_count = select(2, line:gsub("{", ""))
			local close_count = select(2, line:gsub("}", ""))
			content_depth = content_depth + open_count - close_count

			if content_depth <= 0 and line:match("^%s*}%s*$") then
				in_content_block = false
			end
		else
			local ts_start, ts_end = line:find("%[%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d%]")
			if ts_start then
				table.insert(highlights, hl.region(line_idx, ts_start - 1, ts_end, "StackLogTimestamp"))

				-- Match log level [LEVEL]
				local lvl_start, lvl_end = line:find("%[%w+%]", ts_end + 1)
				if lvl_start then
					local level_name = line:sub(lvl_start + 1, lvl_end - 1)
					local level_group = "StackLog" .. level_name

					table.insert(highlights, hl.region(line_idx, lvl_start - 1, lvl_end, level_group))

					if lvl_end < #line then
						table.insert(highlights, hl.region(line_idx, lvl_end, #line, "StackLogContent"))
						local content_part = line:sub(lvl_end + 1)
						local open_count = select(2, content_part:gsub("{", ""))
						local close_count = select(2, content_part:gsub("}", ""))
						if open_count > close_count then
							in_content_block = true
							content_depth = open_count - close_count
						end
					end
				end
			end
		end
	end

	hl.apply(buf, highlights)
end

return M
