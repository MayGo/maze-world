local function clientSlotsCount(playerId, slotsCount)
	assert(typeof(playerId) == 'string')

	return {
		type = script.Name,
		playerId = playerId,
		slotsCount = slotsCount,
		replicateTo = playerId,
	}
end

return clientSlotsCount