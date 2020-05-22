local function setRoomStartTime(roomId, startTime, playersStarting)
    return {
        type = script.Name,
        roomId = roomId,
        startTime = startTime,
        playersStarting = playersStarting
    }
end

return setRoomStartTime
