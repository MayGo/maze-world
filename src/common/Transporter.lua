local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local ModelManager = require(Modules.src.ModelManager)

local Place = game.Workspace:WaitForChild('Place')
local Spawns = Place.Spawns:GetChildren()

local Transporter = {}

local offset = Vector3.new(0, 5, 0)

function freezeCharacter(character, isAnchored)
	for _, part in pairs(character:GetChildren()) do
		if part:IsA('BasePart') then
			part.Anchored = isAnchored
		end
	end
end

function Transporter:fadePlayerTo(player, a, b, c)
	for transparency = a, b, c do
		-- go from a to b, counting by c
		if player.Character then
			for _, v in ipairs(player.Character:GetDescendants()) do
				if v:IsA('BasePart') and v.Name ~= 'HumanoidRootPart' or v:IsA('Decal') then
					v.Transparency = transparency
				end
			end
			wait(0.1)
		else
			logger:d('No Character found for player:' .. player.Name)
		end
	end
end

function Transporter:transportPlayers(players, target)
	for i, player in pairs(players) do
		if player.Character then
			-- Transporter:fadePlayerTo(player, 0, 1, 0.1) --fade out,

			local rootPart = player.Character.HumanoidRootPart
			if rootPart then
				player:RequestStreamAroundAsync(target.Position)
				rootPart.CFrame = ModelManager:onlyDirection(target.CFrame) + offset
			end
			-- Transporter:fadePlayerTo(player, 1, 0, -0.1) --fade back in
		else
			logger:d('No Character found for player:' .. player.Name)
		end
	end
end

function Transporter:transportByKillingPlayers(players)
	for i, player in pairs(players) do
		if player.Character then
			player.Character.Humanoid.Health = 0
		else
			logger:d('No Character found for player:' .. player.Name)
		end
	end
end

function Transporter:teleportTo(player, target)
	-- fadePlayerTo(player, 0, 1, 0.1) --fade out,
	if player.Character then
		local rootPart = player.Character.HumanoidRootPart
		if rootPart then
			player:RequestStreamAroundAsync(target.Position)

			rootPart.CFrame = ModelManager:onlyDirection(target.CFrame) + offset
		end
	else
		logger:d('No Character found for player:' .. player.Name)
	end
	-- fadePlayerTo(player, 1, 0, -0.1) --fade back in
end

function Transporter:placePlayerToHomeSpawn(player)
	local RandomSpawn = Spawns[math.random(1, #Spawns)]
	player.RespawnLocation = RandomSpawn
	Transporter:teleportTo(player, RandomSpawn)
end

function Transporter:placePlayersToHomeSpawn(players)
	for i, player in pairs(players) do
		Transporter:placePlayerToHomeSpawn(player)
	end
end

return Transporter