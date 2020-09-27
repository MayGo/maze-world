local Root = script:FindFirstAncestor('MazeGenerator')
local Roact = require(Root.Roact)
local Plugin = Root.Plugin

local Config = require(Plugin.Config)

local Theme = require(Plugin.Components.Theme)
local Panel = require(Plugin.Components.Panel)
local FitList = require(Plugin.Components.FitList)
local FitText = require(Plugin.Components.FitText)
local FormButton = require(Plugin.Components.FormButton)
local FormTextInput = require(Plugin.Components.FormTextInput)
local PluginSettings = require(Plugin.Components.PluginSettings)
local MaterialsDropdown = require(Plugin.Components.MaterialsDropdown)

local e = Roact.createElement

local ConnectPanel = Roact.Component:extend('ConnectPanel')

function ConnectPanel:init()
	self:setState({
		height = Config.defaultWidth,
		width = Config.defaultWidth,
		wallMaterial = Enum.Material.Grass,
		groundMaterial = Enum.Material.Sand,
	})
end

function ConnectPanel:render()
	local generateMaze = self.props.generateMaze

	local textFieldWidth = 200

	return Theme.with(function(theme)
		return PluginSettings.with(function(settings)
			return e(Panel, nil, {
				Layout = e('UIListLayout', {
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Top,
				}),
				Inputs = e(
					FitList,
					{
						containerProps = {
							BackgroundTransparency = 1,
							LayoutOrder = 1,
						},
						layoutProps = {
							FillDirection = Enum.FillDirection.Vertical,
							Padding = UDim.new(0, 8),
						},
						paddingProps = {
							PaddingTop = UDim.new(0, 10),
							PaddingBottom = UDim.new(0, 10),
							PaddingLeft = UDim.new(0, 10),
							PaddingRight = UDim.new(0, 10),
						},
					},
					{
						Height = e(
							FitList,
							{
								fitAxes = 'Y',
								containerProps = {
									LayoutOrder = 1,
									BackgroundTransparency = 1,
									Size = UDim2.new(1, 0, 0, 0),
								},
								layoutProps = {
									FillDirection = Enum.FillDirection.Horizontal,
									Padding = UDim.new(0, 10),
								},
							},
							{
								Label = e(FitText, {
									Kind = 'TextLabel',
									LayoutOrder = 1,
									BackgroundTransparency = 1,
									TextXAlignment = Enum.TextXAlignment.Left,
									Font = theme.TitleFont,
									TextSize = 20,
									Text = 'Height',
									TextColor3 = theme.Text1,
									MinSize = Vector2.new(textFieldWidth, 0),
								}),
								Input = e(FormTextInput, {
									layoutOrder = 2,
									width = UDim.new(0, 70),
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
								fitAxes = 'Y',
								containerProps = {
									LayoutOrder = 2,
									BackgroundTransparency = 1,
									Size = UDim2.new(1, 0, 0, 0),
								},
								layoutProps = {
									FillDirection = Enum.FillDirection.Horizontal,
									Padding = UDim.new(0, 10),
								},
							},
							{
								Label = e(FitText, {
									Kind = 'TextLabel',
									LayoutOrder = 1,
									BackgroundTransparency = 1,
									TextXAlignment = Enum.TextXAlignment.Left,
									Font = theme.TitleFont,
									TextSize = 20,
									Text = 'Width',
									TextColor3 = theme.Text1,
									MinSize = Vector2.new(textFieldWidth, 0),
								}),
								Input = e(FormTextInput, {
									layoutOrder = 2,
									width = UDim.new(0, 70),
									value = self.state.width,
									placeholderValue = Config.defaultWidth,
									onValueChange = function(newValue)
										self:setState({ width = newValue })
									end,
								}),
							}
						),
						wallMaterial = e(
							FitList,
							{
								fitAxes = 'Y',
								containerProps = {
									LayoutOrder = 3,
									BackgroundTransparency = 1,
									Size = UDim2.new(1, 0, 0, 0),
								},
								layoutProps = {
									FillDirection = Enum.FillDirection.Horizontal,
									Padding = UDim.new(0, 10),
								},
							},
							{
								Label = e(FitText, {
									Kind = 'TextLabel',
									LayoutOrder = 1,
									BackgroundTransparency = 1,
									TextXAlignment = Enum.TextXAlignment.Left,
									Font = theme.TitleFont,
									TextSize = 20,
									Text = 'Wall Material',
									TextColor3 = theme.Text1,
									MinSize = Vector2.new(textFieldWidth, 0),
								}),
								MaterialsDropdown = e(MaterialsDropdown, {
									Size = UDim2.new(0, 150, 0, 40),
									LayoutOrder = 2,
									onSelect = function(material)
										warn('Selected material', material)
										self:setState({ wallMaterial = material })
									end,
								}),
							}
						),
						groundMaterial = e(
							FitList,
							{
								fitAxes = 'Y',
								containerProps = {
									LayoutOrder = 4,
									BackgroundTransparency = 1,
									Size = UDim2.new(1, 0, 0, 0),
								},
								layoutProps = {
									FillDirection = Enum.FillDirection.Horizontal,
									Padding = UDim.new(0, 10),
								},
							},
							{
								Label = e(FitText, {
									Kind = 'TextLabel',
									LayoutOrder = 1,
									BackgroundTransparency = 1,
									TextXAlignment = Enum.TextXAlignment.Left,
									Font = theme.TitleFont,
									TextSize = 20,
									Text = 'Ground Material',
									TextColor3 = theme.Text1,
									MinSize = Vector2.new(textFieldWidth, 0),
								}),
								MaterialsDropdown = e(MaterialsDropdown, {
									Size = UDim2.new(0, 150, 0, 40),
									LayoutOrder = 2,
									onSelect = function(material)
										warn('Selected ground material', material)
										self:setState({ groundMaterial = material })
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
									wallMaterial = self.state.wallMaterial,
									groundMaterial = self.state.groundMaterial,
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