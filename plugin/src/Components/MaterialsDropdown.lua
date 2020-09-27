local Root = script:FindFirstAncestor('MazeGenerator')
local Plugin = Root.Plugin

local Roact = require(Root.Roact)
local M = require(Root.M)

local DropdownMenu = require(Plugin.Components.DropdownMenu)

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
	local tagMap = {}

	local materials = Enum.Material:GetEnumItems()
	for index, material in pairs(materials) do
		tagMap[index] = material

		table.insert(options, material.Name)
	end

	local mergedProps = M.extend(self.props, {
		options = options,
		onSelect = function(newIndex)
			local tag = tagMap[newIndex]
			onSelect(tag)
		end,
	})

	return Roact.createElement(DropdownMenu, mergedProps)
end

return MaterialsDropdown