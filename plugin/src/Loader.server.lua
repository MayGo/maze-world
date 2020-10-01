-- Taken from https://github.com/tiffany352/Roblox-Tag-Editor/blob/bd48fb7ceea6bcd1cd9c515891ae4eb4eb9d1a71/src/Loader.server.lua#L24

-- Sanity check.
if not plugin then
	error('Hot reloader must be executed as a plugin!')
end

-- Change to true to enable hot reloading support. Opening a place
-- containing the code synced via Rojo will cause the plugin to be
-- reloaded in edit mode. (No need for play solo or the hotswap plugin.)
local Config = require(script.Parent.Config)
local useDevSource = Config.isDevBuild
local ServerStorage = game:GetService('ServerStorage')
local PluginFolderName = 'MazeGeneratorPlugin'
local devSource = ServerStorage:FindFirstChild(PluginFolderName)

-- The source that's shipped integrated into the plugin.
local builtinSource = script.Parent.Parent

-- `source` is where we should watch for changes.
-- `currentRoot` is the clone we make of source to avoid require()
-- returning stale values.
local source = builtinSource
local currentRoot = source

local PluginFacade = {
	_toolbars = {},
	_pluginGuis = {},
	_buttons = {},
	_watching = {},
	_beforeUnload = nil,
}

--[[
	Abstraction for plugin:CreateToolbar
]]
function PluginFacade:toolbar(name)
	if self._toolbars[name] then
		return self._toolbars[name]
	end

	local toolbar = plugin:CreateToolbar(name)

	self._toolbars[name] = toolbar

	return toolbar
end
function PluginFacade:GetSetting(name)
	return plugin:GetSetting(name)
end
function PluginFacade:SetSetting(name)
	return plugin:SetSetting(name)
end

--[[
	Abstraction for toolbar:CreateButton
]]
function PluginFacade:button(toolbar, name, tooltip, icon)
	local existingButtons = self._buttons[toolbar]

	if existingButtons then
		local existingButton = existingButtons[name]

		if existingButton then
			return existingButton
		end
	else
		existingButtons = {}
		self._buttons[toolbar] = existingButtons
	end

	local button = toolbar:CreateButton(name, tooltip, icon)

	existingButtons[name] = button

	return button
end

--[[
	Wrapper around plugin:CreatePluginGui
]]
function PluginFacade:createDockWidgetPluginGui(name, ...)
	if self._pluginGuis[name] then
		return self._pluginGuis[name]
	end

	local gui = plugin:CreateDockWidgetPluginGui(name, ...)
	self._pluginGuis[name] = gui

	return gui
end

--[[
	Sets the method to call the next time the system tries to reload
]]
function PluginFacade:beforeUnload(callback)
	self._beforeUnload = callback
end

function PluginFacade:_load(savedState)
	local Plugin = currentRoot:WaitForChild('Plugin')
	local Main = Plugin:WaitForChild('Main')
	local ok, result = pcall(require, Main)

	if not ok then
		warn('Plugin failed to load: ' .. result)
		return
	end

	local MainPluginScript = result

	ok, result = pcall(MainPluginScript, PluginFacade, savedState)

	if not ok then
		warn('Plugin failed to run: ' .. result)
		return
	end
end

function PluginFacade:unload()
	if self._beforeUnload then
		local saveState = self._beforeUnload()
		self._beforeUnload = nil

		return saveState
	end
end

function PluginFacade:_reload()
	local saveState = self:unload()
	currentRoot = source:Clone()

	self:_load(saveState)
end

function PluginFacade:_watch(instance)
	if self._watching[instance] then return end

	-- Don't watch ourselves!
	if instance == script then return end

	local connection1 = instance.Changed:Connect(function(prop)
		print('Reloading due to', instance:GetFullName())

		self:_reload()
	end)

	local connection2 = instance.ChildAdded:Connect(function(instance)
		self:_watch(instance)
	end)

	local connections = { connection1, connection2 }

	self._watching[instance] = connections

	for _, child in ipairs(instance:GetChildren()) do
		self:_watch(child)
	end
end

if useDevSource then
	if devSource ~= nil then
		source = devSource
		currentRoot = source
	else
		warn(
			'MazeGenerator development source is not present, running using built-in source. Waiting for ' .. PluginFolderName .. ' into ServerStorage.'
		)
		local connection
		connection = ServerStorage.ChildAdded:Connect(function(child)
			print('ServerStorage changed', child.Name)
			if child.Name == PluginFolderName then
				print('Got ' .. PluginFolderName .. 'Reloading plugin.', child.Name)
				connection:Disconnect()
				source = ServerStorage:WaitForChild(PluginFolderName)
				currentRoot = source
				PluginFacade:_load()
				PluginFacade:_watch(source)
			end
		end)
	end
end

PluginFacade:_load()
PluginFacade:_watch(source)