local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc

local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local Frame = require(clientSrc.Components.common.Frame)
local Notification = require(clientSrc.Components.common.Notification)
local M = require(Modules.M)
local createElement = Roact.createElement
local Notifications = Roact.PureComponent:extend('Notifications')

local Theme = require(Modules.src.Theme)

local NOTIFICATION_TIME = 10

local PADDING = 0.01

function Notifications:init()
	self.steppedConn = game:GetService('RunService').Stepped:connect(function()
		debug.profilebegin('notify')
		if self.rerenderUntilNoNotifications then
			self:setState({})
		end
		debug.profileend()
	end)
end

function Notifications:willUnmount()
	self.steppedConn:Disconnect()
end

function Notifications:render()
	local notifs = {}
	local children = {}

	local paddingProp = UDim.new(PADDING, 0)

	for idx, notification in ipairs(self.props.notifications) do
		local timeSince = os.time() - notification.time
		local id = notification.time

		if timeSince < NOTIFICATION_TIME then
			notifs['notification_' .. id] = createElement(Notification, {
				text = notification.text or 'N/A',
				thumbnail = notification.thumbnail,
				statusColor = notification.status,
				rectSize = notification.rectSize,
				rectOffset = notification.rectOffset,
				layoutIndex = idx,
			})
		end
	end

	self.rerenderUntilNoNotifications = M.count(notifs) > 0

	children.listLayout = createElement('UIListLayout', {
		Padding = paddingProp,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
	})
	children.padding = createElement('UIPadding', {
		PaddingBottom = paddingProp,
		PaddingLeft = paddingProp,
		PaddingRight = paddingProp,
		PaddingTop = paddingProp,
	})

	return createElement(
		Frame,
		{
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, 0, 1, 0),
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
		},
		M.extend(children, notifs)
	)
end

local NotificationsConnected = RoactRodux.connect(function(state)
	return { notifications = state.messages.notifications }
end)(Notifications)

return NotificationsConnected