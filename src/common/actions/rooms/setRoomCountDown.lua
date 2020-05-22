local function setRoomCountDown(roomId, countDown)
    return {type = script.Name, roomId = roomId, countDown = countDown}
end

return setRoomCountDown
