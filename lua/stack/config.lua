---@class Stack.config_Handler
local M = {}
require("stack.meta.types")

---@type Stack.Config
local Options = {
	log = { notify = true, level = vim.log.levels.DEBUG, log_file = vim.fn.stdpath("cache") .. "/stack/stack.log" },
}

function M.get_config()
	return vim.deepcopy(Options)
end

-- Update the default config
---@param config? Stack.Config
---@return Stack.Config
local function extend(config)
	if not config then
		return vim.deepcopy(Options)
	end
	return vim.tbl_deep_extend("force", vim.deepcopy(Options), config)
end

local function validate_config()
	return true
end

function M.setup(opts)
	local config = extend(opts)

	local is_valid, error_message = validate_config()
	if not is_valid then
		error(string.format("Invalid configuration: %s", error_message))
	end

	Options = config
end

return M
