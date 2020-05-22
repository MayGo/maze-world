local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local StringUtils = require(Modules.src.utils.StringUtils)
local GhostAbility = require(Modules.src.GhostAbility)
local Players = game:GetService('Players')

local PlayerUtils = {}

function PlayerUtils:isHuman(hit)
	if GhostAbility:getGhostCollisionGroupId() == hit.CollisionGroupId then return end

	if hit.Parent == nil then
		return false
	end
	local humanoid = hit.Parent:FindFirstChild('HumanoidRootPart')
	if humanoid then
		return true
	end

	return false
end

function PlayerUtils:getPlayerFromHuman(hit)
	if PlayerUtils:isHuman(hit) then
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		return player
	end

	return nil
end

function PlayerUtils:getPlayer(hit)
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	return player
end

local function IsPartInRegion(part, region)
	local list = workspace:FindPartsInRegion3WithIgnoreList(region, _G.ignorecommon)
	for i = 1, #list do
		if list[i] == part then
			return true
		end
	end
	return false
end

local function IsHumanoidInRegion(region)
	local list = workspace:FindPartsInRegion3WithIgnoreList(region, _G.ignorecommon)
	for i = 1, #list do
		if list[i].Name == 'Torso' then
			local hum = list[i].Parent:FindFirstChild('Humanoid')
			if hum then
				return hum
			end
		end
	end
	return nil
end

function CreateRegion3FromPart(Part)
	return Region3.new(Part.Position - (Part.Size / 2), Part.Position + (Part.Size / 2))
end

function GetPlayersInPart(part)
	local region = CreateRegion3FromPart(part)
	local partsInRegion = workspace:FindPartsInRegion3(region, nil, math.huge)
	local players = {}
	for _, Part in pairs(partsInRegion) do
		local player = game.Players:GetPlayerFromCharacter(Part.Parent)
		if player then
			table.insert(players, player)
		end
	end
	return players
end

return PlayerUtils