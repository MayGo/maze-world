local Root = script:FindFirstAncestor('MazeGenerator')
local Plugin = Root.Plugin

local Roact = require(Root.Roact)
local Log = require(Root.Log)

local Assets = require(Plugin.Assets)
local Config = require(Plugin.Config)
local Version = require(Plugin.Version)
local preloadAssets = require(Plugin.preloadAssets)
local strict = require(Plugin.strict)
local MazeGenerator = require(Plugin.Maze.MazeGenerator)

local SettingsForm = require(Plugin.Components.SettingsForm)

local e = Roact.createElement

local selection = game:GetService('Selection')

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
		self.props.plugin:CreateDockWidgetPluginGui('Root-' .. self.displayedVersion, widgetInfo)
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

function App:generateMaze(settings)
	MazeGenerator:generate(settings)
end

function App:render()
	local children

	children = { SettingsForm = e(SettingsForm, {
		generateMaze = function(settings)
			self:generateMaze(settings)
		end,
		cancel = function()
			Log.trace('Canceling session configuration')

			self:setState({ appStatus = AppStatus.NotStarted })
		end,
	}) }

	return e(Roact.Portal, { target = self.dockWidget }, children)
end

function App:didMount()
	Log.trace('Root {} initializing', self.displayedVersion)

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