local Root = script:FindFirstAncestor('MazeGeneratorPlugin')
local Plugin = Root.Plugin

local Roact = require(Root:WaitForChild('Roact'))
local M = require(Root.M)
local FitScrollingFrame = require(Plugin.Components.FitScrollingFrame)

local RoundButton = require(Plugin.Components.RoundButton)
local DropdownItem = require(Plugin.Components.DropdownMenuItem)

local DropdownMenu = Roact.Component:extend('DropdownMenu')

local e = Roact.createElement

local function noop()
end

function DropdownMenu:init()
	local value = self.props.value
	local options = self.props.options

	if value then
		self:setState({
			selectedIndex = M.findIndex(options, function(v)
				return v.value == value
			end),
			expanded = false,
		})
	else
		self:setState({
			selectedIndex = 1,
			expanded = false,
		})
	end
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
		menuOptions[option] = e(DropdownItem, {
			option = option,
			index = index,
			color = color,
			onActivated = function()
				self:setState({ selectedIndex = index })
				self:toggle()
				onSelect(option.value)
			end,
		})
	end

	local menu = e(
		FitScrollingFrame,
		{
			fitAxes = 'Y',
			containerProps = {
				Size = UDim2.new(1, 0, 0, 400),
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

	local text = defaultText or 'N/A'

	local image = ''

	if options[selectedIndex] then
		text = options[selectedIndex].name
		image = options[selectedIndex].image
	end

	local img = e('ImageButton', {
		LayoutOrder = 1,
		Image = image,
		Size = UDim2.new(0, 40, 0, 40),
		Position = UDim2.new(1, 45, 0, 0),
		AnchorPoint = Vector2.new(1, 0),
	})

	local button = e(RoundButton, {
		Size = UDim2.new(1, 0, 0, 40),
		Text = text,
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

	return e('Frame', frameProps, {
		button = button,
		img = img,
		menu = menu,
	})
end

return DropdownMenu