local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local assets = require(Modules.src.assets)
local logger = require(Modules.src.utils.Logger)

local clientSendNotification = require(Modules.src.actions.toClient.clientSendNotification)

local STORE_MOST_PLAYED = 'MostPlayed'
local STORE_MOST_COINS = 'PlayerCoins'
local STORE_PLAYER_VISITS = 'PlayerVisits'

local datastore = game:GetService('DataStoreService')

local mostCoinsStore = datastore:GetOrderedDataStore(STORE_MOST_COINS)
local visitsDataStore = datastore:GetOrderedDataStore(STORE_PLAYER_VISITS)

local Promise = require(Modules.Promise)

local GameDatastore = require(Modules.src.GameDatastore)

local Leaderboards = {}

local LEADERBOARD_SIZE = 50

local REWARD_10TIMES = 1000
local REWARD_DAILY = 100

function Leaderboards:connectPlayerVisits(player, store)
	local playerKey = player.Name
	local visits
	local success, err = pcall(function()
		visits = visitsDataStore:IncrementAsync(playerKey, 1)
	end)

	local lastLogin = GameDatastore:getLastLogin(player)
	local hours = (os.time() - lastLogin) / 60 / 60

	wait(7)

	if hours >= 24 then
		logger:d(
			'Player ' .. player.Name .. ' last login was ' .. tostring(
				hours
			) .. ' ago. Give reward.',
			lastLogin
		)
		GameDatastore:incrementCoins(player, REWARD_DAILY)
		store:dispatch(
			clientSendNotification(
				player,
				'Daily visit. Reward: ' .. REWARD_DAILY .. ' coins',
				assets.money['coins-pile']
			)
		)
	end

	if success and visits == 10 then
		logger:d(
			'Player ' .. player.Name .. ' has visited  ' .. tostring(
				visits
			) .. ' times. Give reward.'
		)
		GameDatastore:incrementCoins(player, REWARD_10TIMES)
		store:dispatch(
			clientSendNotification(
				player,
				'You visited 10 times. Reward: ' .. REWARD_10TIMES .. ' coins',
				assets.money['coins-pile']
			)
		)
	end

	GameDatastore:setLastLogin(player)

	logger:d('Player ' .. player.Name .. ' has visited ' .. visits .. ' times.')
end

local function updateMostCoins(player, playerData)
	return Promise.async(function(resolve, reject)
		local playerKey = player.Name

		logger:d('DataStore Leaderboard: Update player ' .. player.Name .. ' most coins')
		local success, response =
			pcall(mostCoinsStore.SetAsync, mostCoinsStore, playerKey, playerData.coins)

		if not success then
			logger:e('Failure during updating top coins: ' .. response)
			reject(response)
		else
			resolve(response)
		end
	end)
end

function Leaderboards:connectMostCoins(player)
	local updateLeaderboard = function(playerData)
		--[[	mostCoinsStore:UpdateAsync(playerKey, function(oldValue)
					local newValue = oldValue or 0
					newValue = newValue + playerData.coins
	
					return newValue
				end)]]
		logger:d(
			'DataStore Leaderboard: Player ' .. player.Name .. ' earned ' .. playerData.coins .. ' coins.',
			playerData
		)

		updateMostCoins(player, playerData):andThen(function(body)
			logger:d('DataStore Leaderboard: Saved top coins', body)
		end):catch(function(err)
			logger:e(err)
		end)
	end

	GameDatastore:coinsAfterSave(player, updateLeaderboard)
end

function Leaderboards:updateMostPlayed(player, roomId)
	local key = roomId or ''
	local mostPlayedStore = datastore:GetOrderedDataStore(STORE_MOST_PLAYED .. key)
	local playerKey = player.Name

	logger:d(
		'DataStore Leaderboard: Update Player ' .. player.Name .. ' Most Played for room:',
		roomId
	)

	mostPlayedStore:IncrementAsync(playerKey, 1)
end

function Leaderboards:getMostPlayed(roomId)
	local key = roomId or ''
	local mostPlayedStore = datastore:GetOrderedDataStore(STORE_MOST_PLAYED .. key)
	local pages = mostPlayedStore:GetSortedAsync(false, LEADERBOARD_SIZE)
	local data = pages:GetCurrentPage()
	logger:d('DataStore Leaderboard: Get room Most Played', roomId)
	return data
end

function Leaderboards:getMostVisited()
	local pages = visitsDataStore:GetSortedAsync(false, LEADERBOARD_SIZE)
	local data = pages:GetCurrentPage()
	logger:d('DataStore Leaderboard: Get  Most Visited')
	return data
end

function Leaderboards:getMostCoins()
	local pages = mostCoinsStore:GetSortedAsync(false, LEADERBOARD_SIZE)
	local data = pages:GetCurrentPage()
	logger:d('DataStore Leaderboard: Get  Most Coins')
	return data
end

return Leaderboards