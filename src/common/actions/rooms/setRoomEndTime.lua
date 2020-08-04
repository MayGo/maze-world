local function setRoomEndTime(roomId, endTime)
	return {
		type = script.Name,
		roomId = roomId,
		endTime = endTime,
	}
end

return setRoomEndTime