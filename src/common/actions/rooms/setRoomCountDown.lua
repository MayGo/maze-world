local function setRoomCountDown(roomId, countDownTime, text, textOther)
	return {
		type = script.Name,
		roomId = roomId,
		text = text,
		textOther = textOther,
		countDownTime = countDownTime and os.time() + countDownTime or nil,
	}
end

return setRoomCountDown