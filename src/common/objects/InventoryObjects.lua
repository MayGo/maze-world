local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local GamePasses = require(Modules.src.GamePasses)
local M = require(Modules.M)

local HIGH_JUMP_ID = GamePasses.HIGH_JUMP_ID
local GHOST_MODE_ID = GamePasses.GHOST_MODE_ID

local OBJECT_TYPES = {
	GAME_PASS = 'GAME_PASS',
	PET = 'PET',
	COLLECTABLE = 'COLLECTABLE',
	COIN = 'COIN',
	ROOM = 'ROOM',
}
local PET_TYPES = {
	TRAIL = 'TRAIL',
	SPEED = 'SPEED',
}

local GamePassObjects = {
	[HIGH_JUMP_ID] = GamePasses:getGamePass(HIGH_JUMP_ID),
	[GHOST_MODE_ID] = GamePasses:getGamePass(GHOST_MODE_ID),
}

local PetObjects = {
	[HIGH_JUMP_ID] = GamePasses:getGamePass(HIGH_JUMP_ID),
	[GHOST_MODE_ID] = GamePasses:getGamePass(GHOST_MODE_ID),
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
}

local CoinObjects = {
	['9000001'] = {
		name = '1 coin',
		value = 1,
	},
	['9000005'] = {
		name = '5 coins',
		value = 5,
	},
	['9000008'] = {
		name = '8 coins',
		value = 8,
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

local AllObjects = {}
local ShopObjects = {}
local BuyObjects = {}

M.extend(AllObjects, remappedPet, remappedWorld, remappedGamePasses, remappedRoom)
M.extend(ShopObjects, remappedPet, remappedGamePasses)
M.extend(BuyObjects, remappedPet, remappedGamePasses, remappedRoom)

return {
	OBJECT_TYPES = OBJECT_TYPES,
	PET_TYPES = PET_TYPES,
	HIGH_JUMP_ID = HIGH_JUMP_ID,
	PetObjects = remappedPet,
	GamePassObjects = remappedGamePasses,
	RoomObjects = remappedRoom,
	WorldObjects = remappedWorld,
	CoinObjects = remappedCoins,
	ShopObjects = ShopObjects,
	BuyObjects = BuyObjects,
	AllObjects = AllObjects,
}