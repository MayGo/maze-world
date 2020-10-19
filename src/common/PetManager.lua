local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local src = Modules:WaitForChild('src')
local logger = require(src.utils.Logger)
local InventoryObjects = require(src.objects.InventoryObjects)
local PET_TYPES = InventoryObjects.PET_TYPES
local Pet = require(src:WaitForChild('Pet', 30))
local Print = require(src.utils.Print)
local M = require(Modules.M)

local SlotManager = {}

local PetManager = {}

local characterPets = {}

local characterSlots = {}

local defaultSpeed = 16

function SlotManager:initSlots(character, playerSlotsCount)
	if not characterSlots[character] then
		characterSlots[character] = {}
		for i = 0, playerSlotsCount do
			characterSlots[character][i] = false
		end
	end
end

function SlotManager:findSlot(character)
	local slot = M.find(characterSlots[character], false) or 1

	characterSlots[character][slot] = true
	return slot
end

function SlotManager:clearSlot(character, slot)
	characterSlots[character][slot] = false
	return slot
end

function PetManager:checkAbilities(character)
	local humanoid = character:FindFirstChild('Humanoid')

	function getMaxSpeed(petDeployed)
		if petDeployed.petObject.ability == PET_TYPES.SPEED then
			return petDeployed.petObject.speed
		else
			return defaultSpeed
		end
	end

	local maxSpeed = M.max(M.map(characterPets[character], getMaxSpeed))
	logger:d('Adding speed ability to player', character.Name, maxSpeed)
	humanoid.WalkSpeed = maxSpeed or defaultSpeed
end

function PetManager:addToCharacter(petObjects, character, playerSlotsCount)
	if not character then
		logger:d('No Character found')
		return
	end

	if not characterPets[character] then
		characterPets[character] = {}
		SlotManager:initSlots(character, playerSlotsCount)
	end

	function getPetObject(pet)
		return pet.petObject
	end
	local characterPetObjects = M.map(characterPets[character], getPetObject)

	local deleteObjects = M.difference(characterPetObjects, petObjects)
	local addObjects = M.difference(petObjects, characterPetObjects)

	function deletePet(petObject)
		if characterPets[character][petObject] then
			logger:d('deleting pet' .. petObject.id)
			SlotManager:clearSlot(character, characterPets[character][petObject].slot)

			characterPets[character][petObject]:delete()
			characterPets[character][petObject] = nil
		end
	end
	M.each(deleteObjects, deletePet)

	function addPet(petObject)
		local slotNr = SlotManager:findSlot(character)
		characterPets[character][petObject] = Pet:create(petObject, character, slotNr)
		characterPets[character][petObject]:init()
	end

	M.each(addObjects, addPet)

	PetManager:checkAbilities(character)
end

return PetManager