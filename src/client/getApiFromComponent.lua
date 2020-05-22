--[[
	This is a little utility to pull a ClientApi instance out of Roact's context
	and hand it to a component.

	Check out Components/ApiProvider for an introduction into context and why we
	use this strategy.
]] local function getApiFromComponent(componentInstance)
    local api = componentInstance._context.ClientApi

    if api == nil then
        error("Failed to find ClientApi in component's context!", 2)
    end

    return api
end

return getApiFromComponent
