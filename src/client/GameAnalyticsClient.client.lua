--Variables
--local GameAnalyticsSendMessage = game:GetService("ReplicatedStorage"):WaitForChild("GameAnalyticsSendMessage")

--Services
local GS = game:GetService('GuiService')
local UIS = game:GetService('UserInputService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local Postie = require(Modules.src.utils.Postie)

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