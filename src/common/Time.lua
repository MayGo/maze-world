local Time = {}

function Time.FormatTime(newValue)
	if type(newValue) ~= 'number' then
		return 'd'
	end
	local currentTime = math.max(0, newValue)
	local minutes = math.floor(currentTime / 60) -- % 60
	local seconds = math.floor(currentTime) % 60
	return string.format('%02d:%02d', minutes, seconds)
end

return Time