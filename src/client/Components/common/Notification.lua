local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
-- local logger = require(Modules.src.utils.Logger)
local Roact = require(Modules.Roact)
local createElement = Roact.createElement
local Notification = Roact.Component:extend('Notification')

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

function Notification:render()
	local children = {}

	children.content = createElement(
		'Frame',
		{
			Size = UDim2.new(1, 0, 1, -4),
			BackgroundTransparency = 1,
		},
		{
			listlayout = createElement('UIListLayout', {
				Padding = UDim.new(0, 16),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			uipadding = createElement('UIPadding', {
				PaddingBottom = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 8),
			}),
			thumbnail = createElement('ImageLabel', {
				Size = UDim2.new(0, 64, 0, 64),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				Image = self.props.thumbnail or 'rbxasset://textures/ui/GuiImagePlaceholder.png',
				ImageRectSize = self.props.rectSize or Vector2.new(0, 0),
				ImageRectOffset = self.props.rectOffset or Vector2.new(0, 0),
				LayoutOrder = 1,
			}),
			textLabel = createElement('TextLabel', {
				Size = UDim2.new(1, -80, 0, 50),
				BackgroundTransparency = 1,
				Text = self.props.text or 'N/A',
				Font = Enum.Font.GothamSemibold,
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
			Size = UDim2.new(0, 300, 0, 80),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = self.props.layoutIndex or 0,
		},
		innerFrame
	)
end

return Notification