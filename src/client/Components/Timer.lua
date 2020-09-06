local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
-- local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc

local M = require(Modules.M)
local Roact = require(Modules.Roact)

local Time = require(Modules.src.Time)

local TextLabel = require(clientSrc.Components.common.TextLabel)

local createElement = Roact.createElement
local Timer = Roact.PureComponent:extend('Timer')

function Timer:init()
	self:setState({ currentTime = self.props.initialTime or 0 })
end

function Timer:didMount()
	self.running = true

	-- We don't want to block the main thread, so we spawn a new one!
	spawn(function()
		while self.running do
			self:setState(function(state)
				local updateTime = self.props.key == state.key
				if updateTime then
					return {
						currentTime = state.currentTime + 1,
						initialTime = self.props.initialTime,
					}
				else
					return {
						currentTime = 0,
						initialTime = self.props.initialTime,
						key = self.props.key,
					}
				end
			end)
			wait(1)
		end
	end)
end

function Timer:willUnmount()
	self.running = false
end

function Timer:render()
	local props = self.props
	local initialTime = props.initialTime
	local increment = props.increment
	local duration = initialTime - os.time()

	if increment then
		duration = os.time() - initialTime
	end

	return createElement(
		TextLabel,
		M.extend(M.omit(props, 'increment', 'initialTime', 'key'), {
			Text = Time.FormatTime(duration),
		})
	)
end

return Timer