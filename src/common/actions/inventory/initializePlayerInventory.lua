local function initializePlayerInventory(playerId)
	assert(typeof(playerId) == 'string')

	return {
		type = script.Name,
		playerId = playerId,
	}
end

return initializePlayerInventory