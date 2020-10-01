local Root = script:FindFirstAncestor('MazeGeneratorPlugin')
local Roact = require(Root:WaitForChild('Roact'))
local Plugin = Root.Plugin
local OptionEntry = require(script.Parent.OptionEntry)
local Shortcuts = require(Plugin.Shortcuts)

local OptionsList = Roact.PureComponent:extend('OptionsList')

function OptionsList:init()
	self.state = { selectedItemIndex = 1 } -- first item in the array
end

function OptionsList:changeSelection(increment)
	self:setState(function(prevState, props)
		local nextIndex = prevState.selectedItemIndex + increment

		if nextIndex > #props.items then
			nextIndex = 1
		elseif nextIndex < 1 then
			nextIndex = #props.items
		end

		return { selectedItemIndex = nextIndex }
	end)
end

function OptionsList:render()
	local entrySize = self.props.entrySize
	local children = {}

	children.Layout = Roact.createElement('UIListLayout', {
		Padding = UDim.new(0, 1),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	for index, item in pairs(self.props.items) do
		children[item] = Roact.createElement(OptionEntry, {
			size = entrySize,
			layoutOrder = index,
			text = item,
			isSelected = self.state.selectedItemIndex == index,
		})
	end

	return Roact.createElement(
		'Frame',
		{
			BackgroundTransparency = 1,
			Size = self.props.frameSize,
			LayoutOrder = self.props.layoutOrder,
		},
		children
	)
end

function OptionsList:didMount()
	Shortcuts.bind(Shortcuts.SELECT_UP, function()
		self:changeSelection(-1)
	end)

	Shortcuts.bind(Shortcuts.SELECT_DOWN, function()
		self:changeSelection(1)
	end)
end

function OptionsList:willUnmount()
	Shortcuts.unbind(Shortcuts.SELEC_UP)
	Shortcuts.unbind(Shortcuts.SELEC_DOWN)
end

return OptionsList