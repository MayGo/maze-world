local MazeGenerator = script:FindFirstAncestor('MazeGenerator')
local Plugin = MazeGenerator.Plugin

local Roact = require(MazeGenerator.Roact)

local Config = require(Plugin.Config)

local Theme = require(Plugin.Components.Theme)
local Panel = require(Plugin.Components.Panel)
local FitList = require(Plugin.Components.FitList)
local FitText = require(Plugin.Components.FitText)
local FormButton = require(Plugin.Components.FormButton)
local FormTextInput = require(Plugin.Components.FormTextInput)
local PluginSettings = require(Plugin.Components.PluginSettings)

local e = Roact.createElement

local ConnectPanel = Roact.Component:extend('ConnectPanel')

function ConnectPanel:init()
	self:setState({
		height = 0,
		width = 0,
	})
end

function ConnectPanel:render()
	local generateMaze = self.props.generateMaze

	return Theme.with(function(theme)
		return PluginSettings.with(function(settings)
			return e(Panel, nil, {
				Layout = e('UIListLayout', {
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
				Inputs = e(
					FitList,
					{
						containerProps = {
							BackgroundTransparency = 1,
							LayoutOrder = 1,
						},
						layoutProps = {
							FillDirection = Enum.FillDirection.Horizontal,
							Padding = UDim.new(0, 8),
						},
						paddingProps = {
							PaddingTop = UDim.new(0, 20),
							PaddingBottom = UDim.new(0, 10),
							PaddingLeft = UDim.new(0, 24),
							PaddingRight = UDim.new(0, 24),
						},
					},
					{
						Height = e(
							FitList,
							{
								containerProps = {
									LayoutOrder = 1,
									BackgroundTransparency = 1,
								},
								layoutProps = { Padding = UDim.new(0, 4) },
							},
							{
								Label = e(FitText, {
									Kind = 'TextLabel',
									LayoutOrder = 1,
									BackgroundTransparency = 1,
									TextXAlignment = Enum.TextXAlignment.Left,
									Font = theme.TitleFont,
									TextSize = 20,
									Text = 'Height in blocks',
									TextColor3 = theme.Text1,
								}),
								Input = e(FormTextInput, {
									layoutOrder = 2,
									width = UDim.new(0, 220),
									value = self.state.height,
									placeholderValue = Config.defaultHeight,
									onValueChange = function(newValue)
										self:setState({ height = newValue })
									end,
								}),
							}
						),
						Width = e(
							FitList,
							{
								containerProps = {
									LayoutOrder = 1,
									BackgroundTransparency = 1,
								},
								layoutProps = { Padding = UDim.new(0, 4) },
							},
							{
								Label = e(FitText, {
									Kind = 'TextLabel',
									LayoutOrder = 1,
									BackgroundTransparency = 1,
									TextXAlignment = Enum.TextXAlignment.Left,
									Font = theme.TitleFont,
									TextSize = 20,
									Text = 'Width in blocks',
									TextColor3 = theme.Text1,
								}),
								Input = e(FormTextInput, {
									layoutOrder = 2,
									width = UDim.new(0, 220),
									value = self.state.width,
									placeholderValue = Config.defaultWidth,
									onValueChange = function(newValue)
										self:setState({ width = newValue })
									end,
								}),
							}
						),
					}
				),
				Buttons = e(
					FitList,
					{
						fitAxes = 'Y',
						containerProps = {
							BackgroundTransparency = 1,
							LayoutOrder = 2,
							Size = UDim2.new(1, 0, 0, 0),
						},
						layoutProps = {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Right,
							Padding = UDim.new(0, 8),
						},
						paddingProps = {
							PaddingTop = UDim.new(0, 0),
							PaddingBottom = UDim.new(0, 20),
							PaddingLeft = UDim.new(0, 24),
							PaddingRight = UDim.new(0, 24),
						},
					},
					{ e(FormButton, {
						layoutOrder = 2,
						text = 'Generate',
						onClick = function()
							if generateMaze ~= nil then
								local height = self.state.height
								if height:len() == 0 then
									height = Config.defaultHeight
								end

								local width = self.state.width
								if width:len() == 0 then
									width = Config.defaultWidth
								end

								generateMaze({
									width = width,
									height = height,
								})
							end
						end,
					}) }
				),
			})
		end)
	end)
end

return ConnectPanel