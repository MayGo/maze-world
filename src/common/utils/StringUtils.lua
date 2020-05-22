local StringUtils = {}

function StringUtils:starts_with(str, start)
	return str:sub(1, #start) == start
end
return StringUtils