local function clientSetRoom(player, roomId)
	-- assert(typeof(playerId) == "string")

	return {
		type = script.Name,
		playerId = tostring(player.UserId),
		playerName = tostring(player.Name),
		roomId = roomId,
		replicateTo = tostring(player.UserId),
	}
end

return clientSetRoom