--Variables
--local GameAnalyticsSendMessage = game:GetService("ReplicatedStorage"):WaitForChild("GameAnalyticsSendMessage")

--Services
local GS = game:GetService('GuiService')
local UIS = game:GetService('UserInputService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local Postie = require(Modules.src.utils.Postie)
local ScriptContext = game:GetService('ScriptContext')

ScriptContext.Error:Connect(function(...)
	ReplicatedStorage.GameAnalyticsError:FireServer(...)
end)

--Functions
local function getPlatform()
	if GS:IsTenFootInterface() then
		return 'Console'
	elseif UIS.TouchEnabled and not UIS.MouseEnabled then
		return 'Mobile'
	else
		return 'Desktop'
	end
end

--Filtering
Postie.SetCallback('getPlatform', getPlatform)