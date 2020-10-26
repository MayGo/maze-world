local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local TweenService = game:GetService('TweenService')
local src = Modules:WaitForChild('src')
local Models = ReplicatedStorage:WaitForChild('Models')
local GameDatastore = require(Modules.src.GameDatastore)
local logger = require(src.utils.Logger)
local assets = require(Modules.src.assets)
local clientSendNotification = require(Modules.src.actions.toClient.clientSendNotification)
local M = require(Modules.M)

local LogicTriggerManager = {}

function LogicTriggerManager:flickerLight(light)
	light.Enabled = true
	wait(math.random(1, 10) / 20)
	light.Enabled = false
	wait(math.random(1, 10) / 20)
end

function LogicTriggerManager:shakePart(part, endFunction)
	local info = TweenInfo.new(
		-- Delay between each tween.
		0.05, -- Time
		Enum.EasingStyle.Linear, -- EasingStyle
		Enum.EasingDirection.Out, -- Easing Direction
		50, -- Repeat Count
		true, -- Reverses to initial position? (true/false)
		0.05
	)
	local goals = { Position = part.Position + Vector3.new(0, 0, 0.1) }
	local Tween = TweenService:Create(part, info, goals)
	Tween:Play()

	Tween.Completed:Connect(endFunction)
end

function LogicTriggerManager:collectorTrigger(part, player, playSound, store)
	player.Character.Humanoid:TakeDamage(33)
	playSound('Evil_Laugh', part)

	local bloodMoney = 500
	GameDatastore:incrementCoins(player, bloodMoney)
	store:dispatch(
		clientSendNotification(
			player,
			'The Collector gave ' .. bloodMoney .. ' coins',
			assets.money['coins-pile']
		)
	)
	wait(5)
end

function LogicTriggerManager:ShakeAndFlickerTrigger(part, player, playSound, store)
	local head = part.Parent.monster.PrimaryPart
	playSound('Charlie_Head', head)

	local light = part.Parent.lightPart.PointLight
	local enabled = true
	spawn(function()
		LogicTriggerManager:shakePart(head, function()
			enabled = false
			return
		end)
	end)

	while enabled do
		LogicTriggerManager:flickerLight(light)
	end
end

function LogicTriggerManager:trigger(part, player, playSound, store)
	if part.Name == 'TheCollector' then
		LogicTriggerManager:collectorTrigger(part, player, playSound, store)
	elseif part.Name == 'ShakeAndFlickerTrigger' then
		LogicTriggerManager:ShakeAndFlickerTrigger(part, player, playSound, store)
	end
end

return LogicTriggerManager