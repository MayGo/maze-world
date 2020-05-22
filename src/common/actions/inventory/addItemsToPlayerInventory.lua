local function addItemsToPlayerInventory(playerId, items)
	assert(typeof(playerId) == 'string')
	assert(typeof(items) == 'table' and #items == 0)

	return {
		type = script.Name,
		playerId = playerId,
		items = items,
		replicateTo = playerId,
	}
end

return addItemsToPlayerInventory