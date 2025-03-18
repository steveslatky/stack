local M = {}

function M.decimal_to_hex(decimal)
	if not decimal then
		return "Normal"
	end
	return string.format("#%06x", decimal)
end

return M
