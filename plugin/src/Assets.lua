local strict = require(script.Parent.strict)

local Assets = {
	Sprites = {},
	Slices = {
		RoundBox = {
			asset = 'rbxassetid://2773204550',
			offset = Vector2.new(0, 0),
			size = Vector2.new(32, 32),
			center = Rect.new(4, 4, 4, 4),
		},
	},
	Images = {
		Logo = 'rbxassetid://5747479619',
		Icon = 'rbxassetid://5747497742',
	},
}

local function guardForTypos(name, map)
	strict(name, map)

	for key, child in pairs(map) do
		if type(child) == 'table' then
			guardForTypos(('%s.%s'):format(name, key), child)
		end
	end
end

guardForTypos('Assets', Assets)

return Assets