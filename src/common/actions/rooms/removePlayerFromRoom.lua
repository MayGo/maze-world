local function removePlayerFromRoom(player, roomId)
	-- assert(typeof(playerId) == "string")

	return {
		type = script.Name,
		playerId = tostring(player.UserId),
		playerName = tostring(player.Name),
		roomId = roomId,
	}
end

return removePlayerFromRoom