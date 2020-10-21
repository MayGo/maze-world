local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)

local clientSetGhosting = require(Modules.src.actions.toClient.clientSetGhosting)
local clientReset = require(Modules.src.actions.toClient.clientReset)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc

local Players = game:GetService('Players')

local Roact = require(Modules.Roact)

local Rodux = require(Modules.Rodux)
local RoactRodux = require(Modules.RoactRodux)

local Dict = require(Modules.src.utils.Dict)
local commonReducers = require(Modules.src.commonReducers)
local FlyScript = require(Modules.src.FlyScript)

local clientReducers = require(clientSrc.clientReducers)
local ClientApi = require(clientSrc.ClientApi)

local Game = require(clientSrc.Components.Game)
local ApiProvider = require(clientSrc.Components.ApiProvider)
local AudioPlayer = require(Modules.src.AudioPlayer)

local createElement = Roact.createElement

local LocalPlayer = Players.LocalPlayer

-- The Rodux DevTools aren't available yet! Check the README for more details.
-- local RoduxVisualizer = require(Modules.RoduxVisualizer)

return function(context)
	local reducer = Rodux.combineReducers(Dict.join(commonReducers, clientReducers))

	local api
	local store

	-- We define our main function explicitly instead of running it right away
	-- because we want to make sure we're connected and synced with the server
	-- first.
	local function main()
		local ui =
			Roact.mount(
				createElement(
					RoactRodux.StoreProvider,
					{ store = store },
					{ createElement(ApiProvider, { api = api }, { Game = createElement(Game) }) }
				),
				LocalPlayer.PlayerGui,
				'ClientsMain'
			)

		table.insert(context.destructors, function()
			Roact.unmount(ui)
		end)

		logger:i('Client started!')
	end

	-- This is a custom Rodux middleware that automatically saves any local
	-- actions that are dispatched in order to replay them when we hot-reload.
	local function saveActionsMiddleware(nextDispatch)
		return function(action)
			if not action.replicated then
				table.insert(context.savedActions, action)
			end

			return nextDispatch(action)
		end
	end

	-- Once the Rodux DevTools are available publicly, this will be revisited.
	-- When I was working on this project, I used this config:

	-- local devTools = RoduxVisualizer.createDevTools({
	-- 	mode = RoduxVisualizer.Mode.Integrated,
	-- 	toggleHotkey = Enum.KeyCode.Y,
	-- 	visibleOnStartup = false,
	-- 	attachTo = LocalPlayer:WaitForChild("PlayerGui"),
	-- })

	local storeAction = function(action)
		if store ~= nil then
			store:dispatch(action)
		end
	end
	local clientStartGhosting = function()
		store:dispatch(clientSetGhosting(LocalPlayer))
		logger:d('clientStartGhosting. Start flying')
		local character = LocalPlayer.character
		local humanoid = character:WaitForChild('Humanoid')
		local humanoidRoot = character:WaitForChild('HumanoidRootPart')

		local flyScript = FlyScript:create(humanoidRoot)
		flyScript:initInput()
		flyScript:startFlying()

		humanoid.Died:Connect(function()
			flyScript:endFlying()
			flyScript = nil
			store:dispatch(clientReset(LocalPlayer))
		end)
	end

	local clientPlaySound = function(soundName, triggerPart)
		logger:d('clientPlaySound.' .. soundName, triggerPart)
		AudioPlayer.playAudio(soundName, triggerPart)
	end

	local clientPlayBackgroundSound = function(soundName)
		logger:d('clientPlayBackgroundSound.' .. soundName)

		AudioPlayer.playBackgroundAudio(soundName)
	end

	api = ClientApi.connect({
	-- Apply any saved actions from the last reload.
	-- The actions in this list are only those that were triggered on
	-- the client, since the shared state should already be populated
	-- correctly from the server.
	-- Thunks are functions that we dispatch to the store. It's a
	-- handy way to get a reference to the store and have
	-- side-effects while still looking like regular actions!

	-- This is our custom hot-reloading middleware defined above.

	-- The Redux DevTools middleware, retrieved above.
	-- devTools.middleware,
	--, Rodux.loggerMiddleware
		initialStoreState = function(initialState)
			for _, action in ipairs(context.savedActions) do
				initialState = reducer(initialState, action)
			end

			store =
				Rodux.Store.new(
					reducer,
					initialState,
					{ Rodux.thunkMiddleware, saveActionsMiddleware }
				)

			table.insert(context.destructors, function()
				store:destruct()
			end)

			main()
		end,
		storeAction = storeAction,
		clientStartGhosting = clientStartGhosting,
		clientPlaySound = clientPlaySound,
		clientPlayBackgroundSound = clientPlayBackgroundSound,
	})

	api:clientStart()

	logger:i('Client ready!')
end