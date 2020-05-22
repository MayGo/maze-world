local function clientEquipped(playerId, itemIds)
	assert(typeof(playerId) == 'string')

	return {
		type = script.Name,
		playerId = playerId,
		itemIds = itemIds,
		replicateTo = playerId,
	}
end

return clientEquipped