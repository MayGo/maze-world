local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local GamePasses = require(Modules.src.GamePasses)
local DeveloperProducts = require(Modules.src.DeveloperProducts)
local M = require(Modules.M)

local HIGH_JUMP_ID = GamePasses.HIGH_JUMP_ID
local GHOST_MODE_ID = GamePasses.GHOST_MODE_ID

local OBJECT_TYPES = {
	GAME_PASS = 'Game Passes',
	PET = 'Pets',
	COLLECTABLE = 'Collectables',
	COIN = 'Coins',
	COIN_PACK = 'Coin Packs',
	ROOM = 'Rooms',
}
local PET_TYPES = {
	TRAIL = 'TRAIL',
	SPEED = 'SPEED',
	LIGHT = 'LIGHT',
}

local GamePassObjects = {
	[HIGH_JUMP_ID] = GamePasses:getGamePass(HIGH_JUMP_ID),
	[GHOST_MODE_ID] = GamePasses:getGamePass(GHOST_MODE_ID),
}

local CoinPackObjects = {
	[DeveloperProducts.COINS_1] = DeveloperProducts:getProduct(DeveloperProducts.COINS_1),
	[DeveloperProducts.COINS_2] = DeveloperProducts:getProduct(DeveloperProducts.COINS_2),
	[DeveloperProducts.COINS_3] = DeveloperProducts:getProduct(DeveloperProducts.COINS_3),
	[DeveloperProducts.COINS_4] = DeveloperProducts:getProduct(DeveloperProducts.COINS_4),
}

local PetObjects = {
	['10001'] = {
		name = 'Speed Pet 1',
		price = 300,
		modelName = 'Speed Pet 1',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -3),
		isRotating = false,
		ability = PET_TYPES.SPEED,
		speed = 25,
	},
	['10002'] = {
		name = 'Speed Pet 2',
		price = 1000,
		modelName = 'Speed Pet 2',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -3),
		isRotating = false,
		ability = PET_TYPES.SPEED,
		speed = 35,
	},
	['10003'] = {
		name = 'Speed Pet 3',
		price = 6000,
		modelName = 'Speed Pet 3',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -3),
		isRotating = false,
		ability = PET_TYPES.SPEED,
		speed = 45,
	},
	['10004'] = {
		name = 'Speed Pet 4',
		price = 10000,
		modelName = 'Speed Pet 4',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -3),
		isRotating = false,
		ability = PET_TYPES.SPEED,
		speed = 55,
	},
	['10005'] = {
		name = 'Speed Pet 5',
		price = 60000,
		modelName = 'Speed Pet 5',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -3),
		isRotating = false,
		ability = PET_TYPES.SPEED,
		speed = 65,
	},
	['10006'] = {
		name = 'Speed Pet 6',
		price = 500000,
		modelName = 'Speed Pet 6',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -3),
		isRotating = false,
		ability = PET_TYPES.SPEED,
		speed = 75,
	},
	['20001'] = {
		name = 'Path Pet Red',
		price = 10000,
		modelName = 'Path Pet Red',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -2),
		isRotating = false,
		ability = PET_TYPES.TRAIL,
		trailModelName = 'RedTrail',
	},
	['20002'] = {
		name = 'Path Pet Green',
		price = 10000,
		modelName = 'Path Pet Green',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -2),
		isRotating = false,
		ability = PET_TYPES.TRAIL,
		trailModelName = 'GreenTrail',
	},
	['20003'] = {
		name = 'Path Pet Yellow',
		price = 10000,
		modelName = 'Path Pet Yellow',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -2),
		isRotating = false,
		ability = PET_TYPES.TRAIL,
		trailModelName = 'YellowTrail',
	},
	['20004'] = {
		name = 'Path Pet Rainbow',
		price = 100000,
		modelName = 'Path Pet Rainbow',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -2),
		isRotating = false,
		ability = PET_TYPES.TRAIL,
		trailModelName = 'RainbowTrail',
	},
	['30001'] = {
		name = 'Light Pet 1',
		price = 100,
		modelName = 'Light Pet 1',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -2),
		isRotating = false,
		ability = PET_TYPES.LIGHT,
	},
	['30002'] = {
		name = 'Light Pet 2',
		price = 1000,
		modelName = 'Light Pet 2',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -2),
		isRotating = false,
		ability = PET_TYPES.LIGHT,
	},
	['30003'] = {
		name = 'Light Pet 3',
		price = 9000,
		modelName = 'Light Pet 3',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -2),
		isRotating = false,
		ability = PET_TYPES.LIGHT,
	},
	['30004'] = {
		name = 'Light Pet 4',
		price = 30000,
		modelName = 'Light Pet 4',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -2),
		isRotating = false,
		ability = PET_TYPES.LIGHT,
	},
	['30005'] = {
		name = 'Light Pet 5',
		price = 100000,
		modelName = 'Light Pet 5',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -2),
		isRotating = false,
		ability = PET_TYPES.LIGHT,
	},
}

local WorldObjects = {
	['50000001'] = {
		name = 'Cherry',
		modelName = 'cherry',
		icon = 'rbxassetid://5050640918',
	},
}

local RoomObjects = {
	['10000001'] = {
		name = 'VeryEasy',
		modelName = 'VeryEasyRoom',
		price = 0,
		config = {
			width = 5,
			height = 5,
			prizeCoins = 50,
			playTime = 1 * 60,
		},
	},
	['10000002'] = {
		name = 'Easy',
		modelName = 'EasyRoom',
		price = 500,
		config = {
			width = 10,
			height = 10,
			prizeCoins = 250,
			playTime = 3 * 60,
		},
	},
	['10000003'] = {
		name = 'Normal',
		modelName = 'NormalRoom',
		price = 2000,
		config = {
			width = 15,
			height = 15,
			prizeCoins = 2000,
			playTime = 5 * 60,
		},
	},
	['10000004'] = {
		name = 'Hard',
		modelName = 'HardRoom',
		price = 10000,
		config = {
			width = 20,
			height = 20,
			prizeCoins = 10000,
			playTime = 10 * 60,
		},
	},
	['10000005'] = {
		name = 'Insane',
		modelName = 'InsaneRoom',
		price = 50000,
		config = {
			width = 30,
			height = 30,
			prizeCoins = 10000,
			playTime = 20 * 60,
		},
	},
	['10000006'] = {
		name = 'Crazy',
		modelName = 'CrazyRoom',
		price = 500000,
		config = {
			width = 50,
			height = 50,
			prizeCoins = 600000,
			playTime = 40 * 60,
		},
	},
	['10000007'] = {
		name = 'Exreme',
		modelName = 'ExtremeRoom',
		price = 3000000,
		config = {
			width = 70,
			height = 70,
			prizeCoins = 4000000,
			playTime = 60 * 60,
		},
	},
	['10000008'] = {
		name = 'Impossible',
		modelName = 'ImpossibleRoom',
		price = 20000000,
		config = {
			width = 81,
			height = 81,
			prizeCoins = 20000000,
			playTime = 3 * 60 * 60,
		},
	},
	['10000666'] = {
		name = 'HorrorMaze',
		modelName = 'HorrorMaze',
		config = {
			noTimer = true,
			prizeCoins = 25000,
		},
	},
}

local CoinObjects = {
	['9000001'] = {
		name = 'coin 1',
		value = 1,
	},
	['9000005'] = {
		name = 'coins 5',
		value = 5,
	},
	['9000008'] = {
		name = 'coins 8',
		value = 8,
	},
	['9002008'] = {
		name = 'coins 2418',
		value = 2418,
		onePerPlayer = true,
	},
	['9002009'] = {
		name = 'coins 2578',
		value = 2578,
		onePerPlayer = true,
	},
	['9002010'] = {
		name = 'coins 3113',
		value = 3113,
		onePerPlayer = true,
	},
	['9002011'] = {
		name = 'coins 3671',
		value = 3671,
		onePerPlayer = true,
	},
	['9002012'] = {
		name = 'coins 14628',
		value = 14628,
		onePerPlayer = true,
	},
}

local function keyById(type)
	return function(item, key)
		return M.extend(item, {
			id = key,
			type = type,
		})
	end
end

local remappedPet = M.map(PetObjects, keyById(OBJECT_TYPES.PET))
local remappedWorld = M.map(WorldObjects, keyById(OBJECT_TYPES.COLLECTABLE))
local remappedRoom = M.map(RoomObjects, keyById(OBJECT_TYPES.ROOM))
local remappedCoins = M.map(CoinObjects, keyById(OBJECT_TYPES.COIN))
local remappedGamePasses = M.map(GamePassObjects, keyById(OBJECT_TYPES.GAME_PASS))
local remappedCoinPackObjects = M.map(CoinPackObjects, keyById(OBJECT_TYPES.COIN_PACK))

local AllObjects = {}
local ShopObjects = {}
local BuyObjects = {}

M.extend(
	AllObjects,
	remappedPet,
	remappedWorld,
	remappedGamePasses,
	remappedRoom,
	remappedCoinPackObjects
)

M.extend(ShopObjects, remappedPet, remappedGamePasses, remappedCoinPackObjects)

M.extend(BuyObjects, remappedPet, remappedGamePasses, remappedRoom, remappedCoinPackObjects)

return {
	OBJECT_TYPES = OBJECT_TYPES,
	PET_TYPES = PET_TYPES,
	HIGH_JUMP_ID = HIGH_JUMP_ID,
	PetObjects = remappedPet,
	GamePassObjects = remappedGamePasses,
	CoinPackObjects = remappedCoinPackObjects,
	RoomObjects = remappedRoom,
	WorldObjects = remappedWorld,
	CoinObjects = remappedCoins,
	ShopObjects = ShopObjects,
	BuyObjects = BuyObjects,
	AllObjects = AllObjects,
}