local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
-- local logger = require(Modules.src.utils.Logger)
local Roact = require(Modules.Roact)
local createElement = Roact.createElement
local Notification = Roact.PureComponent:extend('Notification')

--[[
	{
		text = 'N/A',
		thumbnail = 'rbxasset://textures/ui/GuiImagePlaceholder.png',
		rectSize = Vector2.new(0, 0),
		rectOffset = Vector2.new(0, 0),
		statusColor = Color3.fromRGB(20, 20, 40),
		layoutIndex = 0
	}
]]

function Notification:init(initialProps)
	self.ref = Roact.createRef()
end

function Notification:shouldUpdate(nextProps, nextState)
	self.ref.current:TweenPosition(UDim2.new(0, 0, 0, 0), 'Out', 'Quad', 1)
end

function Notification:willUnmount()
end

local PADDING = 0.04

function Notification:render()
	local children = {}

	local paddingProp = UDim.new(PADDING, 0)

	children.content = createElement(
		'Frame',
		{
			Size = UDim2.new(1, 0, 1, -4),
			BackgroundTransparency = 1,
		},
		{
			listlayout = createElement('UIListLayout', {
				Padding = paddingProp,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			uipadding = createElement('UIPadding', {
				PaddingBottom = paddingProp,
				PaddingLeft = paddingProp,
				PaddingRight = paddingProp,
				PaddingTop = paddingProp,
			}),
			thumbnail = createElement(
				'ImageLabel',
				{
					Size = UDim2.new(1, 0, 1, 0),
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
					Image = self.props.thumbnail or 'rbxasset://textures/ui/GuiImagePlaceholder.png',
					ImageRectSize = self.props.rectSize or Vector2.new(0, 0),
					ImageRectOffset = self.props.rectOffset or Vector2.new(0, 0),
					LayoutOrder = 1,
				},
				{ aspect = createElement('UIAspectRatioConstraint') }
			),
			textLabel = createElement('TextLabel', {
				Size = UDim2.new(0.72, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = self.props.text or 'N/A',
				Font = Enum.Font.GothamSemibold,
				TextScaled = true,
				TextSize = 18,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = 2,
			}),
		}
	)

	children.statusBar = createElement('Frame', {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 4),
		BackgroundColor3 = self.props.statusColor or Color3.fromRGB(20, 20, 40),
		BorderSizePixel = 0,
	})

	local innerFrame = createElement(
		'Frame',
		{
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 200, 0, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			[Roact.Ref] = self.ref,
		},
		children
	)
	return createElement(
		'Frame',
		{
			Size = UDim2.new(0.3, 0, 0.3, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = self.props.layoutIndex or 0,
		},
		{
			innerFrame = innerFrame,
			aspect = createElement('UIAspectRatioConstraint', { AspectRatio = 3.5 }),
		}
	)
end

return Notification