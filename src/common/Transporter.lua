local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)

local Place = game.Workspace:WaitForChild('Place')
local Spawns = Place.Spawns:GetChildren()

local Transporter = {}

function Transporter:fadePlayerTo(player, a, b, c)
	for transparency = a, b, c do
		-- go from a to b, counting by c

		for _, part in pairs(player.Character:GetChildren()) do
			-- for each of the objects in the character,

			if part:IsA('BasePart') then
				-- check if it's a part, and if so

				part.Transparency = transparency
				-- set its transparency
			end
		end
		wait(0.1)
	end
end

function Transporter:transportPlayers(players, target)
	for i, player in pairs(players) do
		-- fadePlayerTo(player, 0, 1, 0.1) --fade out,

		player.Character.HumanoidRootPart.CFrame = target.CFrame -- teleport the player
		-- fadePlayerTo(player, 1, 0, -0.1) --fade back in
	end
end

function Transporter:transportByKillingPlayers(players)
	for i, player in pairs(players) do
		player.Character.Humanoid.Health = 0
	end
end

function Transporter:teleportTo(player, target)
	-- fadePlayerTo(player, 0, 1, 0.1) --fade out,
	if player.Character then
		local humanoid = player.Character:FindFirstChildOfClass('Humanoid')
		if humanoid then
			humanoid.RootPart.CFrame = target.CFrame
		end
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