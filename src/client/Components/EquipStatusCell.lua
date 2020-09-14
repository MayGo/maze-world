local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
-- local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc

local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local M = require(Modules.M)
local RoundButton = require(clientSrc.Components.common.RoundButton)
local UIPadding = require(clientSrc.Components.common.UIPadding)
local TextLabel = require(clientSrc.Components.common.TextLabel)

local getApiFromComponent = require(clientSrc.getApiFromComponent)

local InventoryObjects = require(Modules.src.objects.InventoryObjects)
local OBJECT_TYPES = InventoryObjects.OBJECT_TYPES

local createElement = Roact.createElement

local EquipStatusCell = Roact.PureComponent:extend('EquipStatusCell')

function EquipStatusCell:init()
	self.api = getApiFromComponent(self)
end

function EquipStatusCell:render()
	local props = self.props
	local playerSlotsCount = props.playerSlotsCount
	local equippedItems = self.props.equippedItems

	local unequipAll = function()
		self.api:unequipAll()
	end

	local unequipAllButton = createElement(RoundButton, {
		Text = 'Unequip all',
		onClicked = unequipAll,
		Size = UDim2.new(0.8, 0, 0.35, 0),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 0),
	})

	local slotsCount = createElement(
		TextLabel,
		{
			Size = UDim2.new(1, 0, 0.65, 0),
			Position = UDim2.new(0, 0, 0, 0),
			TextScaled = true,
			TextSize = 30,
			AnchorPoint = Vector2.new(0, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Bottom,
			Text = 'Equipped ' .. #equippedItems .. ' / ' .. playerSlotsCount,
		},
		{ UIPadding = createElement(UIPadding, { padding = 10 }) }
	)

	local closeButtonWithCount = createElement(
		'Frame',
		{
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0),
			Size = UDim2.new(0, 100, 0, 100),
			ZIndex = 1,
		},
		{ slotsCount, unequipAllButton }
	)

	return closeButtonWithCount
end

local EquipStatusCellConnected = RoactRodux.connect(function(state)
	local function isVisible(item)
		return item.type ~= OBJECT_TYPES.ROOM
	end
	local function byId(item)
		return item.id, item
	end

	return {
		items = state.shop.items,
		equippedItems = state.player.equippedItems,
		isPlaying = state.player.isPlaying,
		playerSlotsCount = state.player.playerSlotsCount,
		isGhosting = state.player.isGhosting,
		inventory = M.map(M.filter(state.inventory, isVisible), byId),
	}
end)(EquipStatusCell)

return EquipStatusCellConnected