local Root = script:FindFirstAncestor('MazeGeneratorPlugin')
local Roact = require(Root:WaitForChild('Roact'))
local Plugin = Root.Plugin
local RoactRodux = require(Root.RoactRodux)
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
local SetSettings = require(Plugin.Actions.SetSettings)

local selection = game:GetService('Selection')
local e = Roact.createElement

local SettingsForm = Roact.Component:extend('SettingsForm')

function SettingsForm:init()
	local changeSettings = self.props.changeSettings
	local settings = self.props.settings
	selection.SelectionChanged:Connect(function()
		if #selection:Get() > 0 then
			changeSettings({ location = selection:Get()[1] })
		else
			changeSettings({ location = nil })
		end
	end)
end

function SettingsForm:render()
	local generateMaze = self.props.generateMaze
	local changeSettings = self.props.changeSettings
	local settings = self.props.settings

	return Theme.with(function(theme)
		return PluginSettings.with(function()
			local location = settings.location
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
							LayoutOrder = 2,
							Text = 'Selection/Location/Rotation',
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
							LayoutOrder = 4,
							Text = 'Height',
							theme = theme,
							Input = e(FormTextInput, {
								layoutOrder = 2,
								width = UDim.new(0, 70),
								value = settings.height,
								placeholderValue = Config.defaultHeight,
								onValueChange = function(newValue)
									changeSettings({ height = newValue })
								end,
							}),
						}),
						Width = e(SettingsFormItem, {
							LayoutOrder = 6,
							Text = 'Width',
							theme = theme,
							Input = e(FormTextInput, {
								layoutOrder = 2,
								width = UDim.new(0, 70),
								value = settings.width,
								placeholderValue = Config.defaultWidth,
								onValueChange = function(newValue)
									changeSettings({ width = newValue })
								end,
							}),
						}),
						partThickness = e(SettingsFormItem, {
							LayoutOrder = 8,
							Text = 'Thickness',
							theme = theme,
							Input = e(FormTextInput, {
								layoutOrder = 2,
								width = UDim.new(0, 70),
								value = settings.partThickness,
								onValueChange = function(newValue)
									changeSettings({ partThickness = newValue })
								end,
							}),
						}),
						wallMaterial = e(SettingsFormItem, {
							LayoutOrder = 9,
							Text = 'Wall Material',
							theme = theme,
							Input = e(MaterialsDropdown, {
								Size = UDim2.new(0, 200, 1, 0),
								LayoutOrder = 2,
								value = settings.wallMaterial,
								onSelect = function(material)
									warn(material)
									changeSettings({ wallMaterial = material })
								end,
							}),
						}),
						groundMaterial = e(SettingsFormItem, {
							LayoutOrder = 11,
							Text = 'Ground Material',
							theme = theme,
							Input = e(MaterialsDropdown, {
								Size = UDim2.new(0, 200, 1, 0),
								LayoutOrder = 2,
								value = settings.groundMaterial,
								onSelect = function(material)
									changeSettings({ groundMaterial = material })
								end,
							}),
						}),
						onlyBlocks = e(SettingsFormItem, {
							LayoutOrder = 14,
							Text = 'Use only blocks',
							theme = theme,
							Input = e(Checkbox, {
								layoutOrder = 2,
								checked = settings.onlyBlocks,
								onChange = function(newValue)
									changeSettings({ onlyBlocks = newValue })
								end,
							}),
						}),
						addRandomModels = e(SettingsFormItem, {
							LayoutOrder = 16,
							Text = 'Random models',
							theme = theme,
							Input = e(Checkbox, {
								layoutOrder = 2,
								checked = settings.addRandomModels,
								onChange = function(newValue)
									changeSettings({ addRandomModels = newValue })
								end,
							}),
						}),
						addStartAndFinish = e(SettingsFormItem, {
							LayoutOrder = 18,
							Text = 'Start and Finish',
							theme = theme,
							Input = e(Checkbox, {
								layoutOrder = 2,
								checked = settings.addStartAndFinish,
								onChange = function(newValue)
									changeSettings({ addStartAndFinish = newValue })
								end,
							}),
						}),
						addKillBlocks = e(SettingsFormItem, {
							LayoutOrder = 20,
							Text = 'Killblocks',
							theme = theme,
							Input = e(Checkbox, {
								layoutOrder = 2,
								checked = settings.addKillBlocks,
								onChange = function(newValue)
									changeSettings({ addKillBlocks = newValue })
								end,
							}),
						}),
						addCeiling = e(SettingsFormItem, {
							LayoutOrder = 22,
							Text = 'Ceiling',
							theme = theme,
							Input = e(Checkbox, {
								layoutOrder = 2,
								checked = settings.addCeiling,
								onChange = function(newValue)
									changeSettings({ addCeiling = newValue })
								end,
							}),
						}),
						Button = e(FormButton, {
							text = 'Generate',
							LayoutOrder = 30,
							onClick = function()
								if generateMaze ~= nil then
									local height = settings.height
									if height:len() == 0 then
										height = Config.defaultHeight
									end

									local width = settings.width
									if width:len() == 0 then
										width = Config.defaultWidth
									end
									local partThickness = settings.partThickness
									if partThickness:len() == 0 then
										partThickness = Config.defaultThickness
									end

									generateMaze({
										width = width,
										height = height,
										partThickness = partThickness,
										wallMaterial = settings.wallMaterial,
										groundMaterial = settings.groundMaterial,
										addRandomModels = settings.addRandomModels,
										addStartAndFinish = settings.addStartAndFinish,
										addKillBlocks = settings.addKillBlocks,
										addCeiling = settings.addCeiling,
										onlyBlocks = settings.onlyBlocks,
										location = settings.location or workspace,
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

local SettingsFormConnected = RoactRodux.connect(
	function(state)
		local settings = state.settings

		return { settings = settings }
	end,
	function(dispatch)
		return { changeSettings = function(settings)
			dispatch(SetSettings(settings))
		end }
	end
)(SettingsForm)

return SettingsFormConnected