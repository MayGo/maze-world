local Root = script:FindFirstAncestor('MazeGeneratorPlugin')
local Plugin = Root.Plugin

local Roact = require(Root:WaitForChild('Roact'))

local Config = require(Plugin.Config)
local Version = require(Plugin.Version)
local Assets = require(Plugin.Assets)
local Theme = require(Plugin.Components.Theme)

local url = 'https://www.roblox.com/games/3376915546/Maze-World'
local gameId = '3376915546'
local e = Roact.createElement

local Footer = Roact.Component:extend('Footer')

function Footer:init()
	self.footerSize, self.setFooterSize = Roact.createBinding(Vector2.new())
	self.footerVersionSize, self.setFooterVersionSize = Roact.createBinding(Vector2.new())
end

function Footer:render()
	return Theme.with(function(theme)
		return e(
			'Frame',
			{
				LayoutOrder = 3,
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundColor3 = theme.Background2,
				BorderSizePixel = 0,
				ZIndex = 2,
			},
			{
				Padding = e('UIPadding', {
					PaddingTop = UDim.new(0, 4),
					PaddingBottom = UDim.new(0, 4),
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
				}),
				LogoContainer = e(
					'Frame',
					{
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 0, 0, 32),
					},
					{ Logo = e('ImageButton', {
						Image = Assets.Images.Logo,
						Size = UDim2.new(0, 120, 0, 40),
						ScaleType = Enum.ScaleType.Fit,
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 0, 1, 0),
						AnchorPoint = Vector2.new(0, 1),
					}) }
				),
				Link = e('TextLabel', {
					Position = UDim2.new(0.4, 0, 0, 0),
					Size = UDim2.new(0, 100, 1, 0),
					AnchorPoint = Vector2.new(0, 0),
					Font = theme.TitleFont,
					TextSize = 14,
					Text = 'Game id: ' .. gameId,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextColor3 = theme.Text2,
					BackgroundTransparency = 1,
				}),
				Version = e('TextLabel', {
					Position = UDim2.new(1, 0, 0, 0),
					Size = UDim2.new(0, 0, 1, 0),
					AnchorPoint = Vector2.new(1, 0),
					Font = theme.TitleFont,
					TextSize = 18,
					Text = Version.display(Config.version),
					TextXAlignment = Enum.TextXAlignment.Right,
					TextColor3 = theme.Text2,
					BackgroundTransparency = 1,
					[Roact.Change.AbsoluteSize] = function(rbx)
						self.setFooterVersionSize(rbx.AbsoluteSize)
					end,
				}),
			}
		)
	end)
end

return Footer