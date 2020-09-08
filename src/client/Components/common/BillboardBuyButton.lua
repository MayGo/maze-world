local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')

local ContextActionService = game:GetService('ContextActionService')

local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc
local UICorner = require(clientSrc.Components.common.UICorner)
local YAxisBillboard = require(clientSrc.Components.common.YAxisBillboard)
local Roact = require(Modules.Roact)
local UIPadding = require(clientSrc.Components.common.UIPadding)
local TouchItem = require(Modules.src.TouchItem)
local getApiFromComponent = require(clientSrc.getApiFromComponent)
local createElement = Roact.createElement
local BillboardBuyButton = Roact.PureComponent:extend('BillboardBuyButton')

function BillboardBuyButton:init()
	self.api = getApiFromComponent(self)
	self.triggerRef = Roact.createRef()
end

function BillboardBuyButton:didMount()
	local touchPart = self.triggerRef.current

	local function handleAction(actionName, inputState)
		if inputState == Enum.UserInputState.Begin then
			self.props.onClicked()
		end
	end

	self.connection = TouchItem.create(
		touchPart,
		function()
			logger:d('Added Interact bind')
			ContextActionService:BindAction(
				'Interact',
				handleAction,
				true,
				Enum.KeyCode.E,
				Enum.KeyCode.ButtonR1
			)

			self:setState(function()
				return { interactActive = true }
			end)
			ContextActionService:SetTitle('Interact', 'Buy')
		end,
		function()
			logger:d('Removed Interact bind')
			ContextActionService:UnbindAction('Interact')
			self:setState(function()
				return { interactActive = false }
			end)
		end
	)
end

function BillboardBuyButton:willUnmount()
	if self.connection then
		self.connection.Disconnect()
		self.connection = nil
		ContextActionService:UnbindAction('Interact')
	end
end

function BillboardBuyButton:render()
	local props = self.props
	local cframe = props.CFrame
	local interactActive = self.state.interactActive

	local eText = createElement(
		'TextButton',
		{
			LayoutOrder = 2,
			TextScaled = true,
			TextSize = 30,
			AnchorPoint = Vector2.new(0, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			BackgroundTransparency = 0.7,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.new(1, 0, 1, 0),
			Text = 'E',
			Transparency = 0.2,
			TextColor3 = Color3.fromRGB(0, 0, 0),
			[Roact.Event.MouseButton1Click] = function() end,
		},
		{
			UICorner = createElement(UICorner, { CornerRadius = UDim.new(0, 100) }),
			UIPadding = createElement(UIPadding, { padding = 5 }),
		}
	)

	local labelE = createElement(
		YAxisBillboard,
		{
			position = (cframe * CFrame.new(Vector3.new(0, 0, -3))).Position,
			size = Vector2.new(1.5, 1.5),
			onClicked = props.onClicked,
		},
		{ eText = eText }
	)

	local size = 13
	local triggerPart = createElement('Part', {
		Size = Vector3.new(size, size, size),
		Position = (cframe * CFrame.new(Vector3.new(0, 0, -3))).Position,
		Transparency = 1,
		Anchored = true,
		Orientation = Vector3.new(0, 0, 90),
		Shape = 'Cylinder',
		CanCollide = false,
		[Roact.Ref] = self.triggerRef,
	})

	return Roact.createFragment({
		triggerPart = triggerPart,
		labelE = interactActive and labelE or nil,
	})
end

return BillboardBuyButton