if not plugin then return end

local Log = require(script.Parent.Log)

local DevSettings = require(script.DevSettings)

Log.setLogLevelThunk(function()
	return DevSettings:getLogLevel()
end)

local Roact = require(script.Parent.Roact)

local App = require(script.Components.App)
local Theme = require(script.Components.Theme)
local PluginSettings = require(script.Components.PluginSettings)

local app =
	Roact.createElement(Theme.StudioProvider, nil, {
		Roact.createElement(
			PluginSettings.StudioProvider,
			{ plugin = plugin },
			{ RootUI = Roact.createElement(App, { plugin = plugin }) }
		),
	})

local tree = Roact.mount(app, nil, 'Root UI')

plugin.Unloading:Connect(function()
	Roact.unmount(tree)
end)