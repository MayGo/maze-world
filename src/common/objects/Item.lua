local HttpService = game:GetService("HttpService")

local function getId() return HttpService:GenerateGUID(false) end

local Item = {}

function Item.new()
    local self = {
        id = getId(),
        name = "Unnamed Item",
        color = Color3.new(1, 0, 0),
        position = Vector3.new(0, 0, 0)
    }

    return self
end

return Item
