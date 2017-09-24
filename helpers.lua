local helpers = {}

-- return the sign of a number (-1, 0, +1)
function helpers.sign(number)
	if number < 0 then 
		return -1
	elseif number > 0 then 
		return 1 
	end
	return 0
end

-- return a shallow copy of a table
function helpers.copy(t)
	local c = {}
	for k, v in pairs(t) do
		c[k] = v
	end
	return c
end

-- steps the current value towards the target by step_size
function helpers.step(current, target, step_size)
	if math.abs(target - current) < step_size then
		return target
	end
	return current + (helpers.sign(target - current) * step_size)
end

-- linearly interpolates between the current and target values
function helpers.lerp(current, target, interp)
	return current + ((target - current) * interp)
end

-- clamps the current value between min_value and max_value
function helpers.clamp(current, min_value, max_value)
	return math.max(math.min(current, max_value), min_value)
end

return helpers