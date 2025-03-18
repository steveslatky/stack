---@class Stack.win.hl
local M = {}

M.ns_id = vim.api.nvim_create_namespace("stack.win")

-- Add this function to hl.lua
function M.setup_highlight_groups(groups)
	for name, attrs in pairs(groups) do
		vim.api.nvim_set_hl(0, name, attrs)
	end
end

-- Define the standard highlight groups
function M.setup_default_groups()
	M.setup_highlight_groups({
		StackHeader = { fg = "#FFD700", bold = true },
		StackLabel = { fg = "#569CD6" },
		StackValue = { fg = "#CE9178" },
	})
end

-- Create a highlight spec for a specific region
---@param line integer 0-based line number
---@param start_col integer|nil 0-based start column
---@param end_col integer|nil 0-based end column (exclusive)
---@param group string Highlight group name
---@return Stack.HighlightSpec
function M.region(line, start_col, end_col, group)
	return {
		group = group,
		line = line,
		start_col = start_col or 0,
		end_col = end_col or #line,
	}
end

-- Find pattern matches in a single line and return highlight specs
---@param line string The text line to search
---@param line_idx integer 0-based line index
---@param pattern string Lua pattern to match
---@param group string Highlight group name
---@return Stack.HighlightSpec[]
function M.find_in_line(line, line_idx, pattern, group)
	local highlights = {}
	local start_idx, end_idx = line:find(pattern)
	if end_idx == nil then
		return highlights
	end
	while start_idx do
		table.insert(
			highlights,
			M.region(
				line_idx,
				start_idx - 1, -- Convert to 0-based
				end_idx, -- end_col is exclusive in nvim highlight API
				group
			)
		)
		start_idx, end_idx = line:find(pattern, end_idx + 1)
	end
	return highlights
end

-- Apply highlights to a buffer
---@param buf integer Buffer handle
---@param highlights Stack.HighlightSpec[] Array of highlight specs
---@param clear? boolean Whether to clear existing highlights first (default: true)
function M.apply(buf, highlights, clear)
	if clear then
		vim.api.nvim_buf_clear_namespace(buf, M.ns_id, 0, -1)
	end

	for _, hl in ipairs(highlights) do
		vim.highlight.range(
			buf,
			M.ns_id,
			hl.group,
			{ hl.line, hl.start_col },
			{ hl.line, hl.end_col },
			{ priority = 50 }
		)
	end
end

--
---@param buf number
---@param content Stack.Win.Content|nil
function M.render(buf, content)
	if not content then
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
		vim.notify("Content is nil", vim.log.levels.WARN)
		return
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, content.lines or {})
	if content.highlights and #content.highlights > 0 then
		M.apply(buf, content.highlights)
	end
end

-- Find all pattern matches in content lines
-- Find all pattern matches in content lines
---@param lines string[] Lines to search
---@param pattern string Lua pattern to match
---@param group string Highlight group name
---@param line_range? {start: integer, ["end"]: integer} Optional range of lines to search (0-based)
---@return Stack.HighlightSpec[]
function M.find_pattern(lines, pattern, group, line_range)
	local highlights = {}
	local start_line = line_range and line_range["start"] or 0
	local end_line = line_range and line_range["end"] or (#lines - 1)

	for i = start_line, end_line do
		local line = lines[i + 1] -- Convert to 1-based for table access
		if line then
			local line_highlights = M.find_in_line(line, i, pattern, group)
			vim.list_extend(highlights, line_highlights)
		end
	end
	return highlights
end

return M
