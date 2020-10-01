local pluginPath = ...

local plugin = remodel.readModelFile(pluginPath)[1]

local marker = Instance.new('Folder')
marker.Name = 'DEV_BUILD'
marker.Parent = plugin

remodel.writeModelFile(plugin, pluginPath)