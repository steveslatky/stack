---@class Slack.Logger to help debug
local M = {}

-- Log levels with numerical values
local levels = {
	DEBUG = 1,
	INFO = 2,
	WARN = 3,
	ERROR = 4,
}

-- Default configuration
local Logger = {
	level = levels.ERROR,
	log_path = vim.fn.stdpath("cache") .. "/slackstack",
}

-- Setup user configuration
function M.setup(opts)
	opts = opts or {}
	-- Set log level
	if opts.level then
		local level_upper = opts.level:upper()
		if levels[level_upper] then
			Logger.level = levels[level_upper]
		else
			vim.notify("Invalid log level: " .. opts.level, vim.log.levels.WARN)
		end
	end
	-- Set log path and ensure directory exists
	if opts.log_path then
		Logger.log_path = opts.log_path
		local log_dir = vim.fn.fnamemodify(Logger.log_path, ":h")
		if vim.fn.isdirectory(log_dir) == 0 then
			vim.fn.mkdir(log_dir, "p")
		end
	end
end

-- Core logging function
local function log(level, message)
	if level < Logger.level then
		return
	end -- Skip if below current level

	-- Get level name from value
	local level_name
	for name, value in pairs(levels) do
		if value == level then
			level_name = name
			break
		end
	end
	if not level_name then
		return
	end -- Invalid level

	-- Format message with timestamp
	local timestamp = os.date("%Y-%m-%d %H:%M:%S")
	local formatted_msg = string.format("[%s] [%s] %s\n", timestamp, level_name, message)

	-- Write to log file
	local file = io.open(Logger.log_path, "a")
	if file then
		file:write(formatted_msg)
		file:close()
	else
		vim.notify("Failed to write log to: " .. Logger.log_path, vim.log.levels.ERROR)
	end
end

-- Helper functions for each log level
function M.debug(message)
	log(levels.DEBUG, message)
end
function M.info(message)
	log(levels.INFO, message)
end
function M.warn(message)
	log(levels.WARN, message)
end
function M.error(message)
	log(levels.ERROR, message)
end

return M
