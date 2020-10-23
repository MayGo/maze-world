local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local src = Modules:WaitForChild('src')
local Models = ReplicatedStorage:WaitForChild('Models')
local GameDatastore = require(Modules.src.GameDatastore)
local logger = require(src.utils.Logger)
local assets = require(Modules.src.assets)
local clientSendNotification = require(Modules.src.actions.toClient.clientSendNotification)
local M = require(Modules.M)

local LogicTriggerManager = {}

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

function LogicTriggerManager:trigger(part, player, playSound, store)
	if part.Name == 'TheCollector' then
		LogicTriggerManager:collectorTrigger(part, player, playSound, store)
	end
end

return LogicTriggerManager