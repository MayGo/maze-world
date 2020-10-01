--[[
	Theming system taking advantage of Roact's new context API.

	Doesn't use colors provided by Studio and instead just branches on theme
	name. This isn't exactly best practice.
]]

-- Studio does not exist outside Roblox Studio, so we'll lazily initialize it
-- when possible.
local _Studio
local function getStudio()
	if _Studio == nil then
		_Studio = settings():GetService('Studio')
	end

	return _Studio
end

local Root = script:FindFirstAncestor('MazeGeneratorPlugin')

local Roact = require(Root:WaitForChild('Roact'))
local Log = require(Root.Log)

local strict = require(script.Parent.Parent.strict)

local lightTheme = strict('Theme', {
	ButtonFont = Enum.Font.SourceSans,
	InputFont = Enum.Font.SourceSans,
	TitleFont = Enum.Font.SourceSans,
	MainFont = Enum.Font.SourceSans,
	Brand1 = Color3.fromRGB(124, 0, 215),
	Text1 = Color3.fromRGB(64, 64, 64),
	Text2 = Color3.fromRGB(160, 160, 160),
	TextOnAccent = Color3.fromRGB(235, 235, 235),
	Background1 = Color3.fromRGB(255, 255, 255),
	Background2 = Color3.fromRGB(235, 235, 235),
})

local darkTheme = strict('Theme', {
	ButtonFont = Enum.Font.SourceSans,
	InputFont = Enum.Font.SourceSans,
	TitleFont = Enum.Font.SourceSans,
	MainFont = Enum.Font.SourceSans,
	Brand1 = Color3.fromRGB(124, 0, 215),
	Text1 = Color3.fromRGB(235, 235, 235),
	Text2 = Color3.fromRGB(200, 200, 200),
	TextOnAccent = Color3.fromRGB(235, 235, 235),
	Background1 = Color3.fromRGB(48, 48, 48),
	Background2 = Color3.fromRGB(64, 64, 64),
})

local Context = Roact.createContext(lightTheme)

local StudioProvider = Roact.Component:extend('StudioProvider')

-- Pull the current theme from Roblox Studio and update state with it.
function StudioProvider:updateTheme()
	local studioTheme = getStudio().Theme

	if studioTheme.Name == 'Light' then
		self:setState({ theme = lightTheme })
	elseif studioTheme.Name == 'Dark' then
		self:setState({ theme = darkTheme })
	else
		Log.warn("Unexpected theme '{}'' -- falling back to light theme!", studioTheme.Name)

		self:setState({ theme = lightTheme })
	end
end

function StudioProvider:init()
	self:updateTheme()
end

function StudioProvider:render()
	return Roact.createElement(
		Context.Provider,
		{ value = self.state.theme },
		self.props[Roact.Children]
	)
end

function StudioProvider:didMount()
	self.connection = getStudio().ThemeChanged:Connect(function()
		self:updateTheme()
	end)
end

function StudioProvider:willUnmount()
	self.connection:Disconnect()
end

local function with(callback)
	return Roact.createElement(Context.Consumer, { render = callback })
end

return {
	StudioProvider = StudioProvider,
	Consumer = Context.Consumer,
	with = with,
}