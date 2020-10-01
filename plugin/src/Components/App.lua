local Root = script:FindFirstAncestor('MazeGeneratorPlugin')
local Plugin = Root.Plugin
local ChangeHistoryService = game:GetService('ChangeHistoryService')
local Roact = require(Root:WaitForChild('Roact'))
local Log = require(Root.Log)

local Config = require(Plugin.Config)
local Version = require(Plugin.Version)
local preloadAssets = require(Plugin.preloadAssets)
local MazeGenerator = require(Plugin.Maze.MazeGenerator)
local SettingsForm = require(Plugin.Components.SettingsForm)

local e = Roact.createElement

local App = Roact.Component:extend('App')

function App:init()
	self.displayedVersion = Version.display(Config.version)
end

function App:generateMaze(settings)
	MazeGenerator:generate(settings)
	ChangeHistoryService:SetWaypoint('Generated Maze')
end

function App:render()
	local children

	children = { SettingsForm = e(SettingsForm, { generateMaze = function(settings)
		self:generateMaze(settings)
	end }) }

	return e(Roact.Portal, { target = self.props.root }, children)
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
end

return App