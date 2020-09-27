local Root = script:FindFirstAncestor('MazeGenerator')
local Plugin = Root.Plugin

local Roact = require(Root.Roact)
local FitList = require(Plugin.Components.FitList)

local RoundButton = require(Plugin.Components.RoundButton)
local DropdownItem = require(Plugin.Components.DropdownMenuItem)

local DropdownMenu = Roact.Component:extend('DropdownMenu')

local function noop()
end

function DropdownMenu:init()
	self:setState({
		selectedIndex = 1,
		expanded = false,
	})
end

function DropdownMenu:toggle()
	self:setState(function(state)
		return { expanded = not state.expanded }
	end)
end

function DropdownMenu:render()
	local options = self.props.options
	local color = self.props.color
	local defaultText = self.props.defaultText
	local expanded = self.state.expanded
	local selectedIndex = self.state.selectedIndex
	local onSelect = self.props.onSelect or noop

	local menuOptions = {}

	for index, option in ipairs(options) do
		menuOptions[option] = Roact.createElement(DropdownItem, {
			option = option,
			index = index,
			color = color,
			onActivated = function()
				self:setState({ selectedIndex = index })
				self:toggle()
				onSelect(index)
			end,
		})
	end

	local menu = Roact.createElement(
		FitList,
		{
			fitAxes = 'Y',
			containerProps = {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 1, 4),
				color = color,
				Visible = expanded,
			},
			layoutProps = { Padding = UDim.new(0, 4) },
			paddingProps = {
				PaddingTop = UDim.new(0, 16),
				PaddingBottom = UDim.new(0, 16),
				PaddingLeft = UDim.new(0, 0),
				PaddingRight = UDim.new(0, 0),
			},
		},
		menuOptions
	)

	local button = Roact.createElement(RoundButton, {
		Size = UDim2.new(1, 0, 0, 40),
		Text = options[selectedIndex] or defaultText or 'N/A',
		onClicked = function()
			self:toggle()
		end,
	})

	local frameProps = {
		Size = self.props.Size,
		Position = self.props.Position,
		AnchorPoint = self.props.AnchorPoint,
		LayoutOrder = self.props.LayoutOrder,
		BackgroundTransparency = 1,
	}

	return Roact.createElement('Frame', frameProps, {
		button = button,
		menu = menu,
	})
end

return DropdownMenu