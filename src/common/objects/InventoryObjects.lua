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
		price = 50,
		modelName = 'Speed Pet 1',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -3),
		isRotating = false,
		ability = PET_TYPES.SPEED,
		speed = 25,
	},
	['10002'] = {
		name = 'Speed Pet 2',
		price = 100,
		modelName = 'Speed Pet 2',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -3),
		isRotating = false,
		ability = PET_TYPES.SPEED,
		speed = 35,
	},
	['10003'] = {
		name = 'Speed Pet 3',
		price = 500,
		modelName = 'Speed Pet 3',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -3),
		isRotating = false,
		ability = PET_TYPES.SPEED,
		speed = 45,
	},
	['10004'] = {
		name = 'Speed Pet 4',
		price = 1500,
		modelName = 'Speed Pet 4',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -3),
		isRotating = false,
		ability = PET_TYPES.SPEED,
		speed = 55,
	},
	['10005'] = {
		name = 'Speed Pet 5',
		price = 3000,
		modelName = 'Speed Pet 5',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -3),
		isRotating = false,
		ability = PET_TYPES.SPEED,
		speed = 65,
	},
	['10006'] = {
		name = 'Speed Pet 6',
		price = 5000,
		modelName = 'Speed Pet 6',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -3),
		isRotating = false,
		ability = PET_TYPES.SPEED,
		speed = 75,
	},
	['20001'] = {
		name = 'Path Pet Red',
		price = 50,
		modelName = 'Path Pet Red',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -2),
		isRotating = false,
		ability = PET_TYPES.TRAIL,
		trailModelName = 'RedTrail',
	},
	['20002'] = {
		name = 'Path Pet Green',
		price = 50,
		modelName = 'Path Pet Green',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -2),
		isRotating = false,
		ability = PET_TYPES.TRAIL,
		trailModelName = 'GreenTrail',
	},
	['20003'] = {
		name = 'Path Pet Yellow',
		price = 50,
		modelName = 'Path Pet Yellow',
		modelFolder = 'Pets',
		cameraOffset = CFrame.new(1, 0.5, -2),
		isRotating = false,
		ability = PET_TYPES.TRAIL,
		trailModelName = 'YellowTrail',
	},
	['20004'] = {
		name = 'Path Pet Rainbow',
		price = 500,
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
local remappedCoins = M.map(CoinObjects, keyById(OBJECT_TYPES.COIN))
local remappedGamePasses = M.map(GamePassObjects, keyById(OBJECT_TYPES.GAME_PASS))

local AllObjects = {}
local ShopObjects = {}

M.extend(AllObjects, remappedPet, remappedWorld, remappedGamePasses)
M.extend(ShopObjects, remappedPet, remappedGamePasses)

return {
	OBJECT_TYPES = OBJECT_TYPES,
	PET_TYPES = PET_TYPES,
	HIGH_JUMP_ID = HIGH_JUMP_ID,
	PetObjects = remappedPet,
	GamePassObjects = remappedGamePasses,
	WorldObjects = remappedWorld,
	CoinObjects = remappedCoins,
	ShopObjects = ShopObjects,
	AllObjects = AllObjects,
}