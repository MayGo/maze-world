local function removeItemFromPlayerInventory(playerId, itemId)
    assert(typeof(playerId) == "string")
    assert(typeof(itemId) == "string")

    return {
        type = script.Name,
        playerId = playerId,
        itemId = itemId,
        replicateTo = playerId
    }
end

return removeItemFromPlayerInventory
