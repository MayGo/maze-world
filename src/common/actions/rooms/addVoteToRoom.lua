local function addVoteToRoom(player, roomId, vote)
	-- assert(typeof(playerId) == "string")

	return {
		type = script.Name,
		playerId = tostring(player.UserId),
		playerName = tostring(player.Name),
		roomId = roomId,
		vote = vote,
	}
end

return addVoteToRoom