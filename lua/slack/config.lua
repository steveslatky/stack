---@class slackstack.config_handler
---@field opts slackstack.config
local M = { opts = {} }

---@class slackstack.config
local Options = {}

function M.get_cofig()
	return M.opts
end

-- Update the default config
---@param config? slackstack.config
---@return slackstack.config
local function extend(config)
	if not config then
		return vim.deepcopy(M.opts)
	end
	return vim.tbl_deep_extend("force", vim.deepcopy(M.opts), config)
end

local function validate_config(config)
	return true
end

function M.setup(opts)
	local config = extend(opts)

	-- Validate configuration
	local is_valid, error_message = validate_config(config)
	if not is_valid then
		error(string.format("Invalid configuration: %s", error_message))
	end

	Options = config
end

return M
