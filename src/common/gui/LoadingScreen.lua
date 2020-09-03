local ContentProvider = game:GetService('ContentProvider')
local TweenService = game:GetService('TweenService')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local assets = require(Modules.src.assets)
local logger = require(Modules.src.utils.Logger)
local rotateCamera = require(Modules.src.gui.RotateCamera)

game.ReplicatedFirst:RemoveDefaultLoadingScreen()

-- Disable the topbar asap
coroutine.wrap(function()
	local timeout = 1
	local t = tick()
	while not pcall(
		game.StarterGui.SetCore,
		game.StarterGui,
		'TopbarEnabled',
		false
	) and tick() - t < timeout do
		wait()
	end
	logger:i('Disabled TopBar and Backpack')
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
end)()

local loadingLogo = assets.brand['loading-logo']
local preloadAssets = { 'rbxassetid://5357049486' }

local LoadingScreen = { loadingLogo }

LoadingScreen.__index = LoadingScreen

local imgW = 1343
local imgH = 1029

local imgRatio = imgW / imgH

function LoadingScreen:show(localPlayer)
	local PlayerGui = localPlayer:WaitForChild('PlayerGui')
	local screen = Instance.new('ScreenGui')
	screen.Parent = PlayerGui
	screen.DisplayOrder = 10

	self.screen = screen
	local logoImage

	ContentProvider:PreloadAsync(preloadAssets, function()
		local aspectRatioConstraint = Instance.new('UIAspectRatioConstraint')

		logoImage = Instance.new('ImageLabel')

		logoImage.Size = UDim2.new(0.8, 0, 0.8, 0)
		logoImage.BackgroundTransparency = 1
		logoImage.AnchorPoint = Vector2.new(.5, .5)
		logoImage.Position = UDim2.new(.5, 0, .5, 0)
		logoImage.Image = loadingLogo

		logoImage.Parent = screen

		aspectRatioConstraint.AspectRatio = imgRatio
		aspectRatioConstraint.Parent = logoImage
		self.logoImage = logoImage
	end)

	local gradient = Instance.new('UIGradient')
	gradient.Color =
		ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.01, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
		}
	gradient.Rotation = -90
	gradient.Parent = logoImage

	local tweenLength = 2
	local tweenInfo = TweenInfo.new(tweenLength, Enum.EasingStyle.Linear)

	local goal = {}
	goal.Offset = Vector2.new(0, -0.9)
	local tween = TweenService:Create(gradient, tweenInfo, goal) -- creates tween
	tween:Play()
	rotateCamera:start()
end

function LoadingScreen:hide()
	self.logoImage:TweenSizeAndPosition(
		UDim2.new(10, 0, 10, 0),
		UDim2.new(-0.4, 0, -0.4, 0),
		'Out',
		'Quad',
		1,
		false,
		function()
			self.screen:Destroy()
		end
	)

	rotateCamera:stop()

	game.StarterGui:SetCore('TopbarEnabled', true)
end

return LoadingScreen