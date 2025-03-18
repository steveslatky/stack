---@diagnostic disable: missing-fields
---@class Stack.Win
---@field id number
---@field buf? number
---@field scratch_buf? number
---@field win? number
---@field buffers table<number>
---@field Options Stack.Win.Config
local M = setmetatable({}, {
	__call = function(t, ...)
		return t.new(...)
	end,
})
M.__index = M

M.hl = require("stack.win.hl")

-- TODO:  <17-03-25, ss> -- add buff enter and buff close

---@type Stack.Win.Config|nil
M.Options = nil
M.Ui = nil
M.Ending_Action = "<cr>"
M.buffers = {}

---@type Stack.Win.Config
M.default_config = {
	w = {
		width = 50,
		height = 1,
		border = "rounded",
		style = "minimal",
		minimal = true,
		relative = true,
		split = "left",
		position = "left",
		focusable = false,
		title = "",
		title_pos = "center",
		footer = " 'q' to Quit ",
		footer_pos = "center",
	},
	b = {
		buflisted = false,
		scratch = true,
		buftype = "nofile",
	},
	keybinds = {
		{ "<Esc>", ":q", "Escape" },
		{ "q", ":q", "Quit" },
	},
	keymap_opts = { noremap = true, silent = true },
	hl_groups = {
		header = "StackHeader",
		label = "StackLabel",
		instruction = "StackInstruction",
	},
	content = {},
}

---@type Stack.Win.Config
---@diagnostic disable-next-line: missing-fields
M.SidePanel = {
	w = {
		width = 30,
		height = vim.o.lines - 4,
		border = "rounded",
		style = "minimal",
		minimal = true,
		relative = false,
		position = "left",
	},
	b = {
		buflisted = false,
		scratch = true,
		buftype = "nofile",
	},
}

---@type Stack.Win.Config
---@diagnostic disable-next-line: missing-fields
M.BottomPanel = {
	w = {
		width = vim.o.columns,
		height = 10,
		split_type = "horizontal",
		split = "below",
		position = "bottom",
		relative = false,
		style = "minimal",
	},
	b = {
		buflisted = false,
		scratch = true,
		buftype = "nofile",
	},
}

---@type Stack.Win.Config
---@diagnostic disable-next-line: missing-fields
M.TopPanel = {
	w = {
		width = vim.o.columns - 4,
		height = 10,
		style = "minimal",
		split_type = "horizontal",
		minimal = true,
		relative = false,
		position = "top",
	},
	b = {
		buflisted = false,
		scratch = true,
		buftype = "nofile",
	},
}

---@type Stack.Win.Config
---@diagnostic disable-next-line: missing-fields
M.CenteredModal = {
	w = {
		width = math.floor(vim.o.columns / 2),
		height = math.floor(vim.o.lines / 2),
		border = "double",
		style = "minimal",
		minimal = true,
		relative = true,
		position = "center",
	},
	b = {
		buflisted = false,
		scratch = true,
		buftype = "nofile",
	},
}

---@type Stack.Win.Config
---@diagnostic disable-next-line: missing-fields
M.FullScreen = {
	w = {
		width = vim.o.columns - 8,
		height = vim.o.lines - 6,
		border = "rounded",
		style = "minimal",
		minimal = true,
		relative = true,
	},
	b = {
		buflisted = false,
		scratch = true,
		buftype = "nofile",
	},
}

---@type Stack.Win.Config
M.animation = {
	w = {
		relative = true,
		row = 1,
		col = 1,
		width = 1,
		height = 1,
		border = "none",
		style = "minimal",
	},
	b = {
		buflisted = false,
		scratch = true,
		buftype = "nofile",
	},
}

---@type Stack.Win.Config
---@diagnostic disable-next-line: missing-fields
M.Notification = {
	w = {
		width = 40,
		height = 5,
		border = "double",
		style = "minimal",
		minimal = true,
		relative = true,
		position = "notify",
		footer = "",
		focusable = false,
	},
	b = {
		buflisted = false,
		scratch = true,
		buftype = "nofile",
	},
	keybinds = { { "q", ":q", "Dismiss" } },
}

-- Update the get_wo function to handle the new position option
local function get_wo()
	local wo = {
		width = M.Options.w.width,
		height = M.Options.w.height,
		style = M.Options.w.minimal and "minimal" or "",
	}

	if M.Options.w.relative then
		wo.relative = "editor"
		wo.title = M.Options.w.title
		wo.title_pos = M.Options.w.title_pos
		wo.footer = M.Options.w.footer
		wo.footer_pos = M.Options.w.footer_pos
		wo.focusable = M.Options.w.focusable
		wo.border = M.Options.w.border

		local position = M.Options.w.position or "center"

		if position == "center" then
			wo.row = math.floor((M.Ui.height - M.Options.w.height) / 2)
			wo.col = math.floor((M.Ui.width - M.Options.w.width) / 2)
		elseif position == "left" then
			wo.row = 2
			wo.col = 2
		elseif position == "right" then
			wo.row = 2
			wo.col = M.Ui.width - M.Options.w.width - 2
		elseif position == "bottom" then
			wo.row = M.Ui.height - M.Options.w.height - 2
			wo.col = 2
		elseif position == "top" then
			wo.row = 2
			wo.col = 2
		elseif position == "notify" then
			wo.row = 2
			wo.col = M.Ui.width - M.Options.w.width - 2
		end
	else -- Not relative window
		if M.Options.w.split_type == "vertical" then
			wo.vertical = true
		else
			wo.vertical = false
		end

		wo.win = 0
		wo.split = M.Options.w.split
		wo.width = M.Options.w.width
		wo.height = M.Options.w.height
	end
	return wo
end

--- Gets options for buffer
local function get_bo()
	return M.Options.b.buflisted, M.Options.b.scratch
end

-- TODO:  <26-02-25 > -- I am not really a fan of how this is done. Clean up properly
--- Setting up controls for the game
---@param buf integer Buffer to display the game
local function setup_keybindings(buf)
	local keymaps = {}
	for _, value in ipairs(M.Options.keybinds) do
		local km_opts = M.Options.keymap_opts
		km_opts.desc = value[3]
		local map = { mode = "n", lhs = value[1], rhs = value[2] .. M.Ending_Action, opts = km_opts }
		table.insert(keymaps, map)
	end

	for _, keymap in ipairs(keymaps) do
		vim.api.nvim_buf_set_keymap(buf, keymap.mode, keymap.lhs, keymap.rhs, { keymaps.opts })
	end
end

M.configs = {
	default = M.default_config,
	side_panel = M.SidePanel,
	bottom_panel = M.BottomPanel,
	top_panel = M.TopPanel,
	centered_modal = M.CenteredModal,
	fullscreen = M.FullScreen,
	animation = M.animation,
	notification = M.Notification,
}

---Gets a deep copy of a window configuration by name
---@param name ("default_config"| "SidePanel"| "BottomPanel"| "TopPanel"| "CenteredModal"| "FullScreen"| "animation"| "Notification")The name of the configuration to get
---@return Stack.Win.Config|nil The requested configuration or nil if not found
function M.get_config(name)
	if not name or type(name) ~= "string" then
		vim.notify("Invalid configuration name", vim.log.levels.ERROR)
		return nil
	end

	if M.configs[name] then
		return vim.deepcopy(M.configs[name])
	end

	vim.notify("Configuration '" .. name .. "' not found", vim.log.levels.WARN)
	return nil
end

---Create a centered window with configuration
---@param config? Stack.Win.Config|nil Configuration overrides
---@return number buf Buffer handle
---@return number win Window handle
function M.create_window(config)
	if config and type(config) ~= "table" then
		vim.notify("Invalid configuration provided to create_window", vim.log.levels.ERROR)
		return -1, -1
	end

	M.Options = vim.tbl_deep_extend("force", M.default_config, config or M.default_config)
	M.Ui = vim.api.nvim_list_uis()[1]

	local buf = vim.api.nvim_create_buf(get_bo())
	if #M.Options.keybinds > 1 then
		setup_keybindings(buf)
	end

	local line_count = vim.api.nvim_buf_line_count(buf)

	local win = vim.api.nvim_open_win(buf, true, get_wo())
	local height_info = vim.api.nvim_win_text_height(win, {
		start_row = 0,
		end_row = line_count - 1,
	})
	-- M.Options.w.height = height_info
	Log.debug(height_info)

	return buf, win
end

--- New stack window
---@param config Stack.Win.Config?
---@return Stack.Win
function M.new(config)
	local self = setmetatable({}, M)
	local buf, win = self.create_window(config)
	self.id = win
	table.insert(self.buffers, buf)

	return self
end

function M.highlight_region(line, start_col, end_col, group)
	return {
		line = line,
		start_col = start_col,
		end_col = end_col,
		group = group,
	}
end

function M.highlight_pattern(lines, pattern, group)
	local highlights = {}
	for line_idx, line in ipairs(lines) do
		local start_idx, end_idx = line:find(pattern)
		while start_idx do
			table.insert(
				highlights,
				M.highlight_region(
					line_idx - 1, -- 0-based indexing
					start_idx - 1,
					end_idx,
					group
				)
			)
			start_idx, end_idx = line:find(pattern, end_idx + 1)
		end
	end
	return highlights
end

---@type Stack.Win.Content
local _ = {
	lines = {
		"┌────────────────┐",
		"│  Stack.win 1.0 │",
		"├────────────────┤",
		"│ New Window     │",
		"│ Open Panel     │",
		"└────────────────┘",
	},
	highlights = {
		{
			group = "StackHeader",
			line = 1,
			start_col = 3,
			end_col = 12,
		},
		{
			group = "StackSelection",
			line = 3,
			start_col = 2,
			end_col = 12,
		},
	},
}

--- Helper to render content
---@param buf number
---@param content Stack.Win.Content|nil path of file to render
function M.render(buf, content)
	vim.api.nvim_buf_clear_namespace(buf, M.hl.ns_id, 0, -1)
	if content and content.lines then
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, content.lines)
	else
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
		vim.notify("Content lines are nil", vim.log.levels.WARN)
		return
	end

	-- TODO:  <17-03-25,ss> -- Update how the highling gets done. We want to include tree sitter and file based highlighting
	for _, highlight in ipairs(content.highlights or {}) do
		vim.highlight.range(
			buf,
			M.hl.ns_id,
			highlight.group,
			{ highlight.line, highlight.start_col },
			{ highlight.line, highlight.end_col },
			{ priority = 50 }
		)
	end
end

--- Helper to render a file
---@param buf number
---@param path string path of file to render
function M.render_file(buf, path)
	local file = io.open(path, "r")
	if file then
		local lines = {}
		for line in file:lines() do
			table.insert(lines, line)
		end
		file:close()

		local content = { lines = lines, highlights = {} }
		M.render(buf, content)
	else
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Error: Could not open file at " .. path })
	end
end

return M
