local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
-- local logger = require(Modules.src.utils.Logger)

local Roact = require(Modules.Roact)
local Support = require(Modules.src.utils.SupportLibrary)
-- Roact
local createElement = Roact.createElement

-- Create component
local ScrollingFrame = Roact.PureComponent:extend'ScrollingFrame'

-- Set defaults
ScrollingFrame.defaultProps = {
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 1, 0),
	CanvasSize = UDim2.new(1, 0, 1, 0),
}

function ScrollingFrame:render()
	local props = Support.CloneTable(self.props)

	-- Include aspect ratio constraint if specified
	if props.AspectRatio then
		local Constraint =
			createElement('UIAspectRatioConstraint', { AspectRatio = props.AspectRatio })

		-- Insert constraint into children
		props[Roact.Children] =
			Support.Merge({ AspectRatio = Constraint }, props[Roact.Children] or {})
	end

	-- Include list layout if specified
	if props.Layout == 'List' then
		local Layout = createElement('UIListLayout', {
			FillDirection = props.LayoutDirection,
			Padding = props.Padding,
			HorizontalAlignment = props.HorizontalAlignment,
			VerticalAlignment = props.VerticalAlignment,
			SortOrder = props.SortOrder or 'LayoutOrder',
			[Roact.Ref] = function(rbx)
				self:UpdateContentSize(rbx)
			end,
			[Roact.Change.AbsoluteContentSize] = function(rbx)
				self:UpdateContentSize(rbx)
			end,
		})

		-- Update size
		props.Size = self:GetSize()
		props.CanvasSize = self:GetCanvasSize()

		-- Insert layout into children
		props[Roact.Children] = Support.Merge({ Layout = Layout }, props[Roact.Children] or {})
	end

	if props.Layout == 'Grid' then
		local Layout = createElement('UIGridLayout', {
			FillDirection = props.LayoutDirection,
			SortOrder = props.SortOrder or 'LayoutOrder',
			HorizontalAlignment = props.HorizontalAlignment or Enum.HorizontalAlignment.Center,
			VerticalAlignment = props.VerticalAlignment or Enum.VerticalAlignment.Top,
			CellSize = props.CellSize,
			CellPadding = props.CellPadding,
			[Roact.Ref] = function(rbx)
				self:UpdateContentSize(rbx)
			end,
			[Roact.Change.AbsoluteContentSize] = function(rbx)
				self:UpdateContentSize(rbx)
			end,
		})

		-- Update size
		props.Size = self:GetSize()
		props.CanvasSize = self:GetCanvasSize()

		-- Insert layout into children
		props[Roact.Children] = Support.Merge({ Layout = Layout }, props[Roact.Children] or {})
	end

	if props.Layout == 'Table' then
		local Layout = createElement('UITableLayout', {
			FillDirection = props.LayoutDirection,
			Padding = props.Padding,
			HorizontalAlignment = props.HorizontalAlignment,
			VerticalAlignment = props.VerticalAlignment,
			SortOrder = props.SortOrder or 'LayoutOrder',
			[Roact.Ref] = function(rbx)
				self:UpdateContentSize(rbx)
			end,
			[Roact.Change.AbsoluteContentSize] = function(rbx)
				self:UpdateContentSize(rbx)
			end,
		})

		-- Update size
		props.Size = self:GetSize()
		props.CanvasSize = self:GetCanvasSize()

		-- Insert layout into children
		props[Roact.Children] = Support.Merge({ Layout = Layout }, props[Roact.Children] or {})
	end

	-- Filter out custom properties
	props.AspectRatio = nil
	props.Layout = nil
	props.LayoutDirection = nil
	props.HorizontalAlignment = nil
	props.VerticalAlignment = nil
	props.SortOrder = nil
	props.Width = nil
	props.Height = nil
	props.CanvasWidth = nil
	props.CanvasHeight = nil
	props.CellSize = nil
	props.CellPadding = nil
	props.Padding = nil

	-- Display component in wrapper

	return createElement('ScrollingFrame', props)
end

function ScrollingFrame:GetSize(ContentSize)
	local props = self.props

	-- Determine dynamic dimensions
	local DynamicWidth = props.Size == 'WRAP_CONTENT' or props.Width == 'WRAP_CONTENT'
	local DynamicHeight = props.Size == 'WRAP_CONTENT' or props.Height == 'WRAP_CONTENT'
	local DynamicSize = DynamicWidth or DynamicHeight

	-- Calculate size based on content if dynamic
	return UDim2.new(
		(ContentSize and DynamicWidth) and UDim.new(0, ContentSize.X) or (typeof(
			props.Width
		) == 'UDim' and props.Width or props.Size.X),
		(ContentSize and DynamicHeight) and UDim.new(0, ContentSize.Y) or (typeof(
			props.Height
		) == 'UDim' and props.Height or props.Size.Y)
	)
end

function ScrollingFrame:GetCanvasSize(ContentSize)
	local props = self.props

	-- Determine dynamic canvas dimensions
	local DynamicCanvasWidth =
		props.CanvasSize == 'WRAP_CONTENT' or props.CanvasWidth == 'WRAP_CONTENT'
	local DynamicCanvasHeight =
		props.CanvasSize == 'WRAP_CONTENT' or props.CanvasHeight == 'WRAP_CONTENT'
	local DynamicCanvasSize = DynamicCanvasWidth or DynamicCanvasHeight

	-- Calculate size based on content if dynamic
	return UDim2.new(
		(ContentSize and DynamicCanvasWidth) and UDim.new(0, ContentSize.X) or (typeof(
			props.CanvasWidth
		) == 'UDim' and props.CanvasWidth or props.CanvasSize.X),
		(ContentSize and DynamicCanvasHeight) and UDim.new(0, ContentSize.Y) or (typeof(
			props.CanvasHeight
		) == 'UDim' and props.CanvasHeight or props.CanvasSize.Y)
	)
end

function ScrollingFrame:UpdateContentSize(Layout)
	if not (Layout and Layout.Parent) then return end

	-- Set container size based on content
	Layout.Parent.Size = self:GetSize(Layout.AbsoluteContentSize)
	Layout.Parent.CanvasSize = self:GetCanvasSize(Layout.AbsoluteContentSize)
end

return ScrollingFrame