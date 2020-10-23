local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)

local addPlayerFinishToRoom = require(Modules.src.actions.rooms.addPlayerFinishToRoom)
local clientFinishGame = require(Modules.src.actions.toClient.clientFinishGame)
local clientSendNotification = require(Modules.src.actions.toClient.clientSendNotification)
local M = require(Modules.M)
local assets = require(Modules.src.assets)
local Transporter = require(Modules.src.Transporter)
local Leaderboards = require(Modules.src.Leaderboards)
local GameDatastore = require(Modules.src.GameDatastore)

local InventoryObjects = require(Modules.src.objects.InventoryObjects)
local RoomObjects = InventoryObjects.RoomObjects

local function calulatePrize(prizeCoins, playersPlaying)
	local function isPlayerFinished(player)
		return player.finishTime ~= nil
	end

	local playersFinished = M.select(playersPlaying, isPlayerFinished)

	local count = M.count(playersFinished)

	logger:d('Players finished', count, playersPlaying)

	if count == 0 and M.count(playersPlaying) == 1 then
		-- solo run gives always half
		return prizeCoins / 2
	elseif count == 0 then
		return prizeCoins
	end

	local newPrize = prizeCoins / (count + 1) * (count * 1.75)
	return math.floor(newPrize / 10) * 10
end

local function playerFinishedRoom(player, roomId)
	return function(store)
		local room = store:getState().rooms[roomId]

		local roomObject = RoomObjects[roomId]
		local config = roomObject.config

		local playerObj = room.playersPlaying[player.UserId]
		if playerObj and playerObj.finishTime then
			logger:d('Player  already finished room:' .. player.Name)
		else
			local coins = calulatePrize(config.prizeCoins, room.playersPlaying)
			logger:d(
				'Player finished room: ' .. player.Name .. '. Transport to lobby. Give money: ' .. coins .. ' coins.'
			)

			Transporter:placePlayersToHomeSpawn({ player })

			store:dispatch(addPlayerFinishToRoom(player, roomId, os.time(), coins))
			store:dispatch(clientFinishGame(player, roomId, os.time(), coins))

			GameDatastore:incrementCoins(player, coins)
			store:dispatch(
				clientSendNotification(
					player,
					'You won ' .. coins .. ' coins',
					assets.money['coins-pile']
				)
			)
			Leaderboards:updateMostPlayed(player)
			Leaderboards:updateMostPlayed(player, roomId)
		end
	end
end

return playerFinishedRoom