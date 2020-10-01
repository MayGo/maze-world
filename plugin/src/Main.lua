local Root = script:FindFirstAncestor('MazeGenerator')

local Plugin = Root.Plugin
local Log = require(Root.Log)

local DevSettings = require(Plugin.DevSettings)

local Roact = require(Root.Roact)

local App = require(Plugin.Components.App)
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
	local toolbar = pluginFacade:toolbar('Maze Generator ' .. displayedVersion)

	if Config.isDevBuild then
		WIDGET_ID = WIDGET_ID .. '_Local'
		PLUGIN_TITLE = PLUGIN_TITLE .. ' (LOCAL)'
	end

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

	local widgetName = WIDGET_ID .. '-' .. displayedVersion
	local dockWidget = pluginFacade:createDockWidgetPluginGui(widgetName, widgetInfo)
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
	local app =
		e(Theme.StudioProvider, nil, {
			e(
				PluginSettings.StudioProvider,
				{ plugin = pluginFacade },
				{ RootUI = e(App, { root = dockWidget }) }
			),
		})

	local instance = Roact.mount(app, dockWidget, 'APP-UI')

	pluginFacade:beforeUnload(function()
		Roact.unmount(instance)
		dockWidgetEnabled:Disconnect()
	end)
end

return Main