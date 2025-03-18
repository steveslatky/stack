local M = {}

vim.api.nvim_set_hl(0, "StackRed", { fg = "#FF0000" })
vim.api.nvim_set_hl(0, "StackGreen", { fg = "#00FF00" })
vim.api.nvim_set_hl(0, "StackGold", { fg = "#FFD700" })
vim.api.nvim_set_hl(0, "StackPurple", { fg = "#9D00FF" })
vim.api.nvim_set_hl(0, "StackCherry", { fg = "#E32636" })
vim.api.nvim_set_hl(0, "StackOrange", { fg = "#FFA500" })
vim.api.nvim_set_hl(0, "StackCyan", { fg = "#00FFFF" })
vim.api.nvim_set_hl(0, "StackWhite", { fg = "#FFFFFF" })
vim.api.nvim_set_hl(0, "StackBlack", { fg = "#000000" })
vim.api.nvim_set_hl(0, "StackMint", { fg = "#64FFDA" })
vim.api.nvim_set_hl(0, "StackBrightPurple", { fg = "#D500F9" })

M.presets = {
	warning = {
		duration = 2000,
		interval = 200,
		highlights = { "StackRed", "StackGold" },
	},
	success = {
		duration = 2000,
		interval = 200,
		highlights = { "StackGreen", "StackCyan" },
	},
	error = {
		duration = 3000,
		interval = 200,
		highlights = { "StackBlack", "StackCherry" },
	},
	win = {
		duration = 5000,
		interval = 150,
		highlights = { "StackGold", "StackCherry", "StackGreen" },
	},
	vapor_wave = {
		duration = 5000,
		interval = 150,
		highlights = { "StackMint", "StackBrightPurple" },
	},
}

--- Register a new preset or update an existing one
---@param name string The preset name
---@param config table Configuration with duration, interval, and highlights
function M.register_preset(name, config)
	M.presets[name] = vim.tbl_deep_extend("force", M.presets[name] or {}, config)
end

--- Flash the border of the window with an array of colors
---@param win_id number
---@param opts string|table|number Preset name, config table, or duration
---@param interval number|nil Only used if opts is duration
---@param highlights table<string>|nil Only used if opts is duration
function M.flash_border(win_id, opts, interval, highlights)
	local config = {}

	if type(opts) == "string" then
		if not M.presets[opts] then
			vim.notify("Unknown animation preset: " .. opts, vim.log.levels.WARN)
			return
		end
		config = vim.deepcopy(M.presets[opts])
	elseif type(opts) == "table" then
		config = vim.deepcopy(opts)
	else
		config = {
			duration = opts,
			interval = interval,
			highlights = highlights,
		}
	end

	config.duration = config.duration or 2000
	config.interval = config.interval or 200
	config.highlights = config.highlights or { "StackBlack", "StackWhite" }

	local timer = vim.uv.new_timer()
	local count = 0
	local max_flashes = config.duration / (config.interval * 2)

	timer:start(0, config.interval, function()
		vim.schedule(function()
			if count >= max_flashes then
				timer:stop()
				timer:close()

				if vim.api.nvim_win_is_valid(win_id) then
					vim.api.nvim_set_option_value("winhighlight", "FloatBorder:FloatBorder", { win = win_id })
				end
				return
			end

			local hl_index = (count % #config.highlights) + 1
			local hl = config.highlights[hl_index]
			if vim.api.nvim_win_is_valid(win_id) then
				vim.api.nvim_set_option_value("winhighlight", "FloatBorder:" .. hl, { win = win_id })
			end
			count = count + 1
		end)
	end)
end

return M
