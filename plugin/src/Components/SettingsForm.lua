local Root = script:FindFirstAncestor('MazeGenerator')
local Roact = require(Root.Roact)
local Plugin = Root.Plugin

local Config = require(Plugin.Config)

local Theme = require(Plugin.Components.Theme)
local Panel = require(Plugin.Components.Panel)
local FitScrollingFrame = require(Plugin.Components.FitScrollingFrame)
local FitText = require(Plugin.Components.FitText)
local FormButton = require(Plugin.Components.FormButton)
local FormTextInput = require(Plugin.Components.FormTextInput)
local PluginSettings = require(Plugin.Components.PluginSettings)
local MaterialsDropdown = require(Plugin.Components.MaterialsDropdown)
local Checkbox = require(Plugin.Components.Checkbox)
local SettingsFormItem = require(Plugin.Components.SettingsFormItem)
local UIPadding = require(Plugin.Components.UIPadding)

local selection = game:GetService('Selection')
local e = Roact.createElement

local SettingsForm = Roact.Component:extend('SettingsForm')

function SettingsForm:init()
	self:setState({
		height = Config.defaultWidth,
		width = Config.defaultWidth,
		wallMaterial = Enum.Material.Grass,
		groundMaterial = Enum.Material.Sand,
		addRandomModels = true,
		addStartAndFinish = true,
		addKillBlocks = true,
		addCeiling = false,
		location = workspace,
	})

	selection.SelectionChanged:Connect(function()
		if #selection:Get() > 0 then
			self:setState({ location = selection:Get()[1] })
		else
			self:setState({ location = nil })
		end
	end)
end

function SettingsForm:render()
	local generateMaze = self.props.generateMaze

	return Theme.with(function(theme)
		return PluginSettings.with(function(settings)
			local location = self.state.location
			local locationName = 'workspace'
			local locationPos = tostring(Vector3.new(0, 0, 0))

			if location and location:IsA('BasePart') then
				locationName = location.Name
				locationPos = tostring(location.Position)
			end

			return e(Panel, nil, {
				Layout = e('UIListLayout', {
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Top,
				}),
				Inputs = e(
					FitScrollingFrame,
					{
						fitAxes = 'Y',
						containerProps = {
							BackgroundTransparency = 1,
							LayoutOrder = 0,
							Size = UDim2.new(1, 0, 1, 0),
						},
						layoutProps = { Padding = UDim.new(0, 8) },
						paddingProps = {
							PaddingTop = UDim.new(0, 10),
							PaddingBottom = UDim.new(0, 10),
							PaddingLeft = UDim.new(0, 10),
							PaddingRight = UDim.new(0, 10),
						},
					},
					{
						UIPadding = e(UIPadding, { padding = 10 }),
						Location = e(SettingsFormItem, {
							LayoutOrder = 0,
							Text = 'Selection/Location',
							theme = theme,
							Input = e(FitText, {
								Kind = 'TextLabel',
								LayoutOrder = 2,
								BackgroundTransparency = 1,
								TextXAlignment = Enum.TextXAlignment.Left,
								Font = theme.TitleFont,
								TextSize = 20,
								Text = locationName .. ' ' .. locationPos,
								TextColor3 = theme.Text1,
							}),
						}),
						Height = e(SettingsFormItem, {
							LayoutOrder = 1,
							Text = 'Height',
							theme = theme,
							Input = e(FormTextInput, {
								layoutOrder = 2,
								width = UDim.new(0, 70),
								value = self.state.height,
								placeholderValue = Config.defaultHeight,
								onValueChange = function(newValue)
									self:setState({ height = newValue })
								end,
							}),
						}),
						Width = e(SettingsFormItem, {
							LayoutOrder = 2,
							Text = 'Width',
							theme = theme,
							Input = e(FormTextInput, {
								layoutOrder = 2,
								width = UDim.new(0, 70),
								value = self.state.width,
								placeholderValue = Config.defaultWidth,
								onValueChange = function(newValue)
									self:setState({ width = newValue })
								end,
							}),
						}),
						wallMaterial = e(SettingsFormItem, {
							LayoutOrder = 3,
							Text = 'Wall Material',
							theme = theme,
							Input = e(MaterialsDropdown, {
								Size = UDim2.new(0, 150, 1, 0),
								LayoutOrder = 2,
								value = self.state.wallMaterial,
								onSelect = function(material)
									warn('Selected material', material)
									self:setState({ wallMaterial = material })
								end,
							}),
						}),
						groundMaterial = e(SettingsFormItem, {
							LayoutOrder = 4,
							Text = 'Ground Material',
							theme = theme,
							Input = e(MaterialsDropdown, {
								Size = UDim2.new(0, 150, 1, 0),
								LayoutOrder = 2,
								value = self.state.groundMaterial,
								onSelect = function(material)
									warn('Selected ground material', material)
									self:setState({ groundMaterial = material })
								end,
							}),
						}),
						addRandomModels = e(SettingsFormItem, {
							LayoutOrder = 5,
							Text = 'Random models',
							theme = theme,
							Input = e(Checkbox, {
								layoutOrder = 2,
								checked = self.state.addRandomModels,
								onChange = function(newValue)
									warn('Add random models', newValue)
									self:setState({ addRandomModels = newValue })
								end,
							}),
						}),
						addStartAndFinish = e(SettingsFormItem, {
							LayoutOrder = 5,
							Text = 'Start and Finish',
							theme = theme,
							Input = e(Checkbox, {
								layoutOrder = 2,
								checked = self.state.addStartAndFinish,
								onChange = function(newValue)
									warn('Add start and finish', newValue)
									self:setState({ addStartAndFinish = newValue })
								end,
							}),
						}),
						addKillBlocks = e(SettingsFormItem, {
							LayoutOrder = 6,
							Text = 'Killblocks',
							theme = theme,
							Input = e(Checkbox, {
								layoutOrder = 2,
								checked = self.state.addKillBlocks,
								onChange = function(newValue)
									warn('Add addKillBlocks', newValue)
									self:setState({ addKillBlocks = newValue })
								end,
							}),
						}),
						addCeiling = e(SettingsFormItem, {
							LayoutOrder = 7,
							Text = 'Ceiling',
							theme = theme,
							Input = e(Checkbox, {
								layoutOrder = 2,
								checked = self.state.addCeiling,
								onChange = function(newValue)
									warn('Add addCeiling', newValue)
									self:setState({ addCeiling = newValue })
								end,
							}),
						}),
						Button = e(FormButton, {
							text = 'Generate',
							LayoutOrder = 8,
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
										addRandomModels = self.state.addRandomModels,
										addStartAndFinish = self.state.addStartAndFinish,
										addKillBlocks = self.state.addKillBlocks,
										addCeiling = self.state.addCeiling,
										location = self.state.location or workspace,
									})
								end
							end,
						}),
					}
				),
			})
		end)
	end)
end

return SettingsForm