local Root = script:FindFirstAncestor('MazeGenerator')
local Plugin = Root.Plugin

local Roact = require(Root.Roact)
local M = require(Root.M)

local DropdownMenu = require(Plugin.Components.DropdownMenu)

local MaterialsDropdown = Roact.Component:extend('MaterialsDropdown')

local tags = { {
	id = 'all',
	name = 'All',
	prefix = '⁉',
}, {
	id = 'material',
	name = 'Material',
	prefix = '🌳',
}, {
	id = 'weapon',
	name = 'Weapon',
	prefix = '💀',
}, {
	id = 'armor',
	name = 'Armor',
	prefix = '👚',
}, {
	id = 'trinket',
	name = 'Trinket',
	prefix = '⚓',
}, {
	id = 'melee',
	name = 'Melee',
	prefix = '⚔',
}, {
	id = 'ranged',
	name = 'Ranged',
	prefix = '🔫',
}, {
	id = 'magic',
	name = 'Magic',
	prefix = '✨',
}, {
	id = 'pet',
	name = 'Pet',
	prefix = '🐶',
}, {
	id = 'cosmetic',
	name = 'Cosmetic',
	prefix = '👑',
}, {
	id = 'reborn',
	name = 'Reborn',
	prefix = '🌟',
}, {
	id = 'event',
	name = 'Event',
	prefix = '🎊',
} }
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