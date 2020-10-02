local settings = require(script.settings)

return function(state, action)
	state = state or {}
	return { settings = settings(state.settings, action) }
end