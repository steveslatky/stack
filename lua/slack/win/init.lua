local M = {}

---@class Slack.Keybinds
---@field desc string
---@field lhs string
---@field rhs string
---@field ending_action string|nil

---@class HlGroups
---@field header string
---@field label string
---@field value string
---@field instruction string

---@class Slack.w
---@field width integer
---@field height integer
---@field border ("none"|"single"|"double"|"rounded"|"solid"|"shadow")
---@field relative boolean
---@field split string
---@field style string

---@class Slack.b
---@field buflisted boolean
---@field buftype string
---@field scratch boolean
---
---@class Slack.Keymap.opts
---@field noremap boolean
---@field silent boolean
---
---@class Slack.Win.Config
---@field w Slack.w
---@field b Slack.b
---@field hl_groups HlGroups
---@field keybinds table<Slack.Keybinds>
---@field keymap_opts table

---@type Slack.Win.Config|nil
Options = nil
Ui = nil
Ending_Action = "<cr>"

---@type Slack.Win.Config
M.default_config = {
	w = {
		width = 50,
		height = 1,
		border = "rounded",
		style = "minimal",
		relative = true,
		split = "splitleft",
	},
	b = {
		buflisted = false,
		scratch = true,
		buftype = "slack",
	},
	keybinds = { { "q", ":q", "Quit" } },
	keymap_opts = { noremap = true, silent = true },
	hl_groups = {
		header = "SlackstackHeader",
		label = "SlackstackLabel",
		value = "SlackstackValue",
		instruction = "SlackstackInstruction",
	},
}

--- Gets options for buffer
local function get_bo()
	return Options.b.buflisted, Options.b.scratch
end

--- Get options for the window
---@return vim.wo
local function get_wo()
	return {
		relative = Options.w.relative and "editor" or "",
		-- split = not Options.w.relative and Options.w.split,
		width = Options.w.width,
		height = Options.w.height,
		row = math.floor((Ui.height - Options.w.height) / 2),
		col = math.floor((Ui.width - Options.w.width) / 2),
		style = Options.w.style,
		border = Options.w.border,
	}
end

--- Setting up controls for the game
---@param buf integer Buffer to display the game
local function setup_keybindings(buf)
	local keymaps = {}
	for _, value in ipairs(Options.keybinds) do
		local km_opts = Options.keymap_opts
		km_opts.desc = value[3]
		local map = { mode = "n", lhs = value[1], rhs = value[2] .. Ending_Action, opts = km_opts }
		table.insert(keymaps, map)
	end

	for _, keymap in ipairs(keymaps) do
		vim.api.nvim_buf_set_keymap(buf, keymap.mode, keymap.lhs, keymap.rhs, { keymaps.opts })
	end
end

---Create a centered window with configuration
---@param config? Slack.Win.Config|nil Configuration overrides
---@return number buf Buffer handle
---@return number win Window handle
function M.create_window(config)
	Options = vim.tbl_deep_extend("force", M.default_config, config or M.default_config)
	Ui = vim.api.nvim_list_uis()[1]

	local win
	local buf = vim.api.nvim_create_buf(get_bo())
	setup_keybindings(buf)
	win = vim.api.nvim_open_win(buf, true, get_wo())

	return buf, win
end

return M
