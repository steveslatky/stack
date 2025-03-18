---@class Stack.Logger to help debug
local M = setmetatable({}, {
	__call = function(t, ...)
		return t.setup(...)
	end,
})
M.__index = M

local win = require("stack.win")

local levels = {
	DEBUG = vim.log.levels.DEBUG,
	INFO = vim.log.levels.INFO,
	WARN = vim.log.levels.WARN,
	ERROR = vim.log.levels.ERROR,
}

-- TODO:  <09-03-25, ss> -- Change this, config is handled in config.lua

-- Default configuration
---@class stack.log.Config
---@field level vim.log.levels
---@field log_file string directory where the log file is stored
local Logger = {
	level = levels.DEBUG,
	log_file = vim.fn.stdpath("cache") .. "/stack/stack.log",
}

-- Setup user configuration
---@param opts stack.log.Config|nil
function M.setup(opts)
	opts = opts or Logger
	M.opts = require("stack.config").get_config()
	vim.tbl_extend("force", vim.deepcopy(Logger), opts)
	if opts.log_file then
		Logger.log_file = opts.log_file
		local log_dir = vim.fn.fnamemodify(Logger.log_file, ":h")
		if vim.fn.isdirectory(log_dir) == 0 then
			vim.fn.mkdir(log_dir, "p")
		end
	end
end

-- Core logging function
---@param level number
---@param message string|table
local function log(level, message)
	if type(message) == "table" then
		message = vim.inspect(message, {
			depth = 10,
			newline = "\n  ",
			indent = " ",
		})
	end
	if level < Logger.level then
		return
	end

	if M.opts.log.notify then
		vim.notify(message, level)
	end

	local level_name
	for name, value in pairs(levels) do
		if value == level then
			level_name = name
			break
		end
	end
	if not level_name then
		return
	end

	local timestamp = os.date("%Y-%m-%d %H:%M:%S")
	local formatted_msg = string.format("[%s] [%s] %s\n", timestamp, level_name, message)

	-- -- TODO:  <12-03-25, ss> -- Make it prepend by default
	-- local file = io.open(Logger.log_file, "a")
	-- if file then
	-- 	file:write(formatted_msg)
	-- 	file:close()
	-- else
	-- 	vim.notify("Failed to write log to: " .. Logger.log_file, vim.log.levels.ERROR)
	-- end

	local existing_content
	local read_file, open_err = io.open(Logger.log_file, "r")
	if read_file then
		existing_content = read_file:read("*a")
		read_file:close()
	elseif open_err and open_err:match("No such file or directory") then
		-- TODO: first time write backup
	else
		vim.notify("Failed to read log file: " .. open_err, vim.log.levels.ERROR)
		return
	end

	-- Write new content followed by existing content
	local file = io.open(Logger.log_file, "w")
	if file then
		file:write(formatted_msg)
		if existing_content then
			file:write(existing_content)
		end
		file:close()
	else
		vim.notify("Failed to write log to: " .. Logger.log_file, vim.log.levels.ERROR)
	end
end

--- Quick access to log file
function M.open_log()
	local opts = win.CenteredModal
	opts.w.title = "Log File"
	opts.w.width = 100
	local buf, _ = win.create_window(opts)
	win.render_file(buf, Logger.log_file)
	require("stack.log.highlights").highlight_log_buffer(buf)

	vim.api.nvim_set_option_value("filetype", "Log", { buf = buf })

	vim.api.nvim_create_autocmd("TextChanged", {
		buffer = buf,
		callback = function()
			require("stack.log.highlights").highlight_log_buffer(buf)
		end,
	})
	vim.api.nvim_create_autocmd("TextChangedI", {
		buffer = buf,
		callback = function()
			require("stack.log.highlights").highlight_log_buffer(buf)
		end,
	})
end

--- Create a debug message
---@param message string|table
function M.debug(message)
	log(vim.log.levels.DEBUG, message)
end
--- Create an info message
---@param message string|table
function M.info(message)
	log(vim.log.levels.INFO, message)
end
--- Create a warn message
---@param message string|table
function M.warn(message)
	log(vim.log.levels.WARN, message)
end
--- Create an error message
---@param message string|table
function M.error(message)
	log(vim.log.levels.ERROR, message)
end

return M
