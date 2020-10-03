local Root = script:FindFirstAncestor('MazeGeneratorPlugin')

local Plugin = Root.Plugin
local Config = require(Plugin.Config)
local M = require(Root.M)

return function(state, action)
	state = state or {
		height = Config.defaultWidth,
		width = Config.defaultWidth,
		wallMaterial = Enum.Material.Grass,
		groundMaterial = Enum.Material.Sand,
		onlyBlocks = false,
		addRandomModels = true,
		addStartAndFinish = true,
		addKillBlocks = true,
		addCeiling = false,
		partThickness = Config.defaultThickness,
		location = workspace,
	}

	if action.type == 'SetSettings' then
		return M.extend({}, state, action.settings)
	end

	return state
end