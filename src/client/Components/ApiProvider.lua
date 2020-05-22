--[[
	This is a simple example of a feature called context.

	Context is unstable, and we're working on building a new, more powerful API
	to replace it: https://github.com/Roblox/roact/issues/4

	Context is usually used for dependency injection, which is what we're doing
	here. This project uses an instance of an object called ClientApi that
	represents our connection to the server and all the actions we can perform.

	We could've crammed that object into a global or module as a singleton
	instead of going through the hassle of dependency injection, but we gain
	some nice things by doing this:

	1. Testing becomes a lot easier, since we can inject exactly the set of fake
		objects we need for a given test, and don't have to worry about mutating
		globals to get mocked behavior.

	2. We can technically replace the API implementation mid-run, which can
		assist in hot-reloading. This isn't taken advantage of right now.

	3. We could have different or multiple API objects in the tree, since
		they're scoped using Roact components.

	To get the API out of context and consume it, there's a handy method named
	getApiFromComponent, which accepts a component instance.
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)

local Roact = require(Modules.Roact)

local ApiProvider = Roact.Component:extend('ApiProvider')

function ApiProvider:init()
	assert(self.props.api ~= nil)

	self._context.ClientApi = self.props.api
end

function ApiProvider:render()
	return Roact.oneChild(self.props[Roact.Children])
end

return ApiProvider