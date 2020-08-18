local function clientSendNotification(player, text, thumbnail)
	--assert(typeof(playerId) == 'string')

	return {
		type = script.Name,
		playerId = tostring(player.UserId),
		replicateTo = tostring(player.UserId),
		text = text,
		thumbnail = thumbnail,
		time = os.time(),
	}
end

return clientSendNotification