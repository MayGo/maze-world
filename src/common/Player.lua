local Player = {}

function Player:getPlayerFromName(name)
    -- loop over all playersWaiting:
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        -- if their name matches (case insensitive), return with that player:
        if player.Name:lower() == name:lower() then return player end
    end
    -- if we reach the end of the for-loop, no player with that name was found
end
return Player
