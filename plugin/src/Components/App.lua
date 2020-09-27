local MazeGenerator = script:FindFirstAncestor('MazeGenerator')
local Plugin = MazeGenerator.Plugin

local Roact = require(MazeGenerator.Roact)
local Log = require(MazeGenerator.Log)

local Assets = require(Plugin.Assets)
local Config = require(Plugin.Config)
local Version = require(Plugin.Version)
local preloadAssets = require(Plugin.preloadAssets)
local strict = require(Plugin.strict)

local ConnectPanel = require(Plugin.Components.ConnectPanel)
local ConnectingPanel = require(Plugin.Components.ConnectingPanel)
local ConnectionActivePanel = require(Plugin.Components.ConnectionActivePanel)
local ErrorPanel = require(Plugin.Components.ErrorPanel)
local SettingsPanel = require(Plugin.Components.SettingsPanel)

local e = Roact.createElement

local AppStatus = strict('AppStatus', {
	NotStarted = 'NotStarted',
	Connecting = 'Connecting',
	Connected = 'Connected',
	Error = 'Error',
	Settings = 'Settings',
})

local App = Roact.Component:extend('App')

function App:init()
	self:setState({
		appStatus = AppStatus.NotStarted,
		errorMessage = nil,
	})

	self.signals = {}
	self.serveSession = nil
	self.displayedVersion = Version.display(Config.version)

	local toolbar = self.props.plugin:CreateToolbar('Maze Generator ' .. self.displayedVersion)

	self.toggleButton =
		toolbar:CreateButton(
			'Maze Generator',
			'Show or hide the Maze Generator panel',
			Assets.Images.Icon
		)
	self.toggleButton.ClickableWhenViewportHidden = true
	self.toggleButton.Click:Connect(function()
		self.dockWidget.Enabled = not self.dockWidget.Enabled
	end)

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

	self.dockWidget =
		self.props.plugin:CreateDockWidgetPluginGui(
			'MazeGenerator-' .. self.displayedVersion,
			widgetInfo
		)
	self.dockWidget.Name = 'Maze Generator ' .. self.displayedVersion
	self.dockWidget.Title = 'Maze Generator ' .. self.displayedVersion
	self.dockWidget.AutoLocalize = false
	self.dockWidget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	self.signals.dockWidgetEnabled = self.dockWidget:GetPropertyChangedSignal('Enabled'):Connect(
		function()
			self.toggleButton:SetActive(self.dockWidget.Enabled)
		end
	)
end

function App:generateMaze()
end

function App:render()
	local children

	if self.state.appStatus == AppStatus.NotStarted then
		children = { ConnectPanel = e(ConnectPanel, {
			generateMaze = function(settings)
				self:generateMaze(settings)
			end,
			cancel = function()
				Log.trace('Canceling session configuration')

				self:setState({ appStatus = AppStatus.NotStarted })
			end,
		}) }
	elseif self.state.appStatus == AppStatus.Connecting then
		children = { ConnectingPanel = e(ConnectingPanel) }
	elseif self.state.appStatus == AppStatus.Connected then
		children = { ConnectionActivePanel = e(ConnectionActivePanel, { stopSession = function()
			Log.trace('Disconnecting session')

			self.serveSession:stop()
			self.serveSession = nil
			self:setState({ appStatus = AppStatus.NotStarted })

			Log.trace('Session terminated by user')
		end }) }
	elseif self.state.appStatus == AppStatus.Settings then
		children = { e(SettingsPanel, { back = function()
			self:setState({ appStatus = AppStatus.NotStarted })
		end }) }
	elseif self.state.appStatus == AppStatus.Error then
		children = { ErrorPanel = e(ErrorPanel, {
			errorMessage = self.state.errorMessage,
			onDismiss = function()
				self:setState({ appStatus = AppStatus.NotStarted })
			end,
		}) }
	end

	return e(Roact.Portal, { target = self.dockWidget }, children)
end

function App:didMount()
	Log.trace('MazeGenerator {} initializing', self.displayedVersion)

	preloadAssets()
end

function App:willUnmount()
	if self.serveSession ~= nil then
		self.serveSession:stop()
		self.serveSession = nil
	end

	for _, signal in pairs(self.signals) do
		signal:Disconnect()
	end
end

return App