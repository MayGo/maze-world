local function setRoomCountDown(roomId, countDownTime, text)
	return {
		type = script.Name,
		roomId = roomId,
		text = text,
		countDownTime = os.time() + countDownTime,
	}
end

return setRoomCountDown