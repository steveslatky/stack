---@class stack.animation.easing
local M = {}

---@param x number
---@return number
function M.easeInSine(x)
	return 1 - math.cos((x * math.pi) / 2)
end

--- Linear in out easing
---@param x number
---@return number
function M.easeInOutSine(x)
	return -(math.cos(math.pi * x) - 1) / 2
end

---@param x number
---@return number
local function easeOutBounce(x)
	local n1 = 7.5625
	local d1 = 2.75

	if x < 1 / d1 then
		return n1 * x * x
	elseif x < 2 / d1 then
		x = x - 1.5 / d1
		return n1 * x * x + 0.75
	elseif x < 2.5 / d1 then
		x = x - 2.25 / d1
		return n1 * x * x + 0.9375
	else
		x = x - 2.625 / d1
		return n1 * x * x + 0.984375
	end
end

--- Bounce easing
---@param x number
---@return number
function M.easeInOutBounce(x)
	if x < 0.5 then
		return (1 - easeOutBounce(1 - 2 * x)) / 2
	else
		return (1 + easeOutBounce(2 * x - 1)) / 2
	end
end

return M
