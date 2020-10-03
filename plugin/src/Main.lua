local Root = script:FindFirstAncestor('MazeGeneratorPlugin')
local Roact = require(Root:WaitForChild('Roact'))
local Plugin = Root.Plugin
local Rodux = require(Root.Rodux)
local RoactRodux = require(Root.RoactRodux)
local Log = require(Root.Log)

local DevSettings = require(Plugin.DevSettings)

local App = require(Plugin.Components.App)
local Reducer = require(Plugin.Reducer)
local Theme = require(Plugin.Components.Theme)
local Assets = require(Plugin.Assets)

local Version = require(Plugin.Version)
local Config = require(Plugin.Config)
local PluginSettings = require(Plugin.Components.PluginSettings)

local e = Roact.createElement
local function Main(pluginFacade, savedState)
	local WIDGET_ID = 'MazeGenerator'
	local PLUGIN_TITLE = 'Maze Generator'
	local PLUGIN_DESC = 'Show or hide the Maze Generator panel'

	-- PLUGIN CONFIGURATION
	local displayedVersion = Version.display(Config.version)

	if Config.isDevBuild then
		displayedVersion = displayedVersion .. '-local'
		WIDGET_ID = WIDGET_ID .. displayedVersion
		PLUGIN_TITLE = PLUGIN_TITLE .. ' (LOCAL)'
	end

	local toolbar = pluginFacade:toolbar('Maze Generator ' .. displayedVersion)

	local widgetInfo = DockWidgetPluginGuiInfo.new(
		-- Minimum size
		Enum.InitialDockState.Right,
		false, -- Initially enabled state
		false, -- Whether to override the widget's previous state
		360,
		190, -- Floating size
		360,
		190
	)

	local dockWidget = pluginFacade:createDockWidgetPluginGui(WIDGET_ID, widgetInfo)
	dockWidget.Name = PLUGIN_TITLE .. ' ' .. displayedVersion
	dockWidget.Title = PLUGIN_TITLE .. '' .. displayedVersion
	dockWidget.AutoLocalize = false
	dockWidget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local toggleButton = pluginFacade:button(toolbar, PLUGIN_TITLE, PLUGIN_DESC, Assets.Images.Icon)
	toggleButton.ClickableWhenViewportHidden = true
	toggleButton.Click:Connect(function()
		dockWidget.Enabled = not dockWidget.Enabled
	end)

	local dockWidgetEnabled = dockWidget:GetPropertyChangedSignal('Enabled'):Connect(function()
		toggleButton:SetActive(dockWidget.Enabled)
	end)

	local unloadConnection
	unloadConnection = dockWidget.AncestryChanged:Connect(function()
		print('New MazeGenerator version coming online; unloading the old version')
		unloadConnection:Disconnect()
		pluginFacade:unload()
	end)

	Log.setLogLevelThunk(function()
		return DevSettings:getLogLevel()
	end)
	--- APP UI
	local store = Rodux.Store.new(Reducer, savedState)
	local app =
		e(Theme.StudioProvider, nil, {
			e(
				PluginSettings.StudioProvider,
				{ plugin = pluginFacade },
				{ RootUI = e(App, { root = dockWidget }) }
			),
		})
	local element = Roact.createElement(RoactRodux.StoreProvider, { store = store }, { app = app })

	local instance = Roact.mount(element, dockWidget, 'APP-UI')

	pluginFacade:beforeUnload(function()
		Roact.unmount(instance)
		dockWidgetEnabled:Disconnect()
		return store:getState()
	end)
end

return Main