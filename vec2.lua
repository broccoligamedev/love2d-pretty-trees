local vec2 = {}

-- return the dot product of a vector
function vec2.dot(x1, y1, x2, y2)
	return (x1 * x2) + (y1 * y2)
end

-- return the '2D crossproduct' of two vectors
function vec2.cross(x1, y1, x2, y2)
	return (x1 * y2) - (y1 * x2)
end

-- return a normalized vector
function vec2.normalize(x1, y1)
	local length = vec2.length(x1, y1)
	if length > 0 then
		return x1 / length, y1 / length
	end
	return 0, 0
end

-- return the length of a vector
function vec2.length(x1, y1)
	return math.sqrt((x1 * x1) + (y1 * y1))
end

-- return a vector rotated by the given degrees
function vec2.rotate(x1, y1, deg)
	local precision = 3
	local multi = 10 ^ precision
	local rad = math.rad(deg)
	local new_x = (x1 * math.cos(rad)) - (y1 * math.sin(rad))
	local new_y = (x1 * math.sin(rad)) + (y1 * math.cos(rad))
	new_x = math.floor(new_x * multi) / multi
	new_y = math.floor(new_y * multi) / multi
	return new_x, new_y
end

-- return the angle in degrees between a vector and the x axis
function vec2.absolute_angle(x1, y1)
    return math.deg(math.atan2(y1, x1))
end

-- return the angle in degrees between two vectors
function vec2.angle_between(x1, y1, x2, y2)
    local theta = math.atan2(y2, x2) - math.atan2(y1, x1)
    return math.deg(theta)
end

-- clamps the magnitude of a vector between min_length and max_length
function vec2.clamp(x, y, min_length, max_length)
	local length = vec2.length(x, y)
	if length > max_length then
		x, y = vec2.normalize(x, y)
		x = x * max_length
		y = y * max_length
	elseif length < min_length then
		x, y = vec2.normalize(x, y)
		x = x * min_length
		y = y * min_length
	end
	return x, y
end

-- shrinks a vector (towards length 0) by a given amount
function vec2.shrink(x, y, shrink_amount)
	if vec2.length(x, y) <= shrink_amount then
		return 0, 0
	end
	local s_x, s_y = vec2.normalize(x, y)
	x = x - (s_x * shrink_amount)
	y = y - (s_y * shrink_amount)
	return x, y
end

return vec2