local Root = script:FindFirstAncestor('MazeGeneratorPlugin')
local Plugin = Root.Plugin

local Roact = require(Root:WaitForChild('Roact'))
local M = require(Root.M)

local DropdownMenu = require(Plugin.Components.DropdownMenu)

local TexturePath = 'rbxasset://textures/TerrainTools/'
local MaterialDetails = require(Plugin.Components.MaterialDetails)
local MaterialsDropdown = Roact.Component:extend('MaterialsDropdown')

local function noop()
end

function MaterialsDropdown:init()
end

function MaterialsDropdown:didMount()
end

function MaterialsDropdown:render()
	local onSelect = self.props.onSelect or noop
	local options = {}

	for index, material in pairs(MaterialDetails) do
		table.insert(options, {
			value = material.enum,
			name = material.enum.Name,
			image = TexturePath .. material.image,
		})
	end

	local mergedProps = M.extend(self.props, {
		options = options,
		onSelect = function(newValue)
			onSelect(newValue)
		end,
	})

	return Roact.createElement(DropdownMenu, mergedProps)
end

return MaterialsDropdown