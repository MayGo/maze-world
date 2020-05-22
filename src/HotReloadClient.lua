local ReplicatedStorage = game:GetService("ReplicatedStorage")

local savedState = nil

local HotReloadClient = {}

function HotReloadClient.start(options)
    local getCurrent = options.getCurrent
    local getNext = options.getNext
    local beforeUnload = options.beforeUnload

    -- The server gets to decide when a hot-reload is triggered.
    local reloadBindable = ReplicatedStorage:WaitForChild("HotReloaded")

    reloadBindable.OnClientInvoke = function()
        reloadBindable.OnClientInvoke = nil

        savedState = beforeUnload()

        -- Do the job of StarterPlayerScripts over again to restart this script.
        -- This feels pretty hacky.
        local current = getCurrent()
        local parent = current.Parent
        local next = getNext()
        current:Destroy()
        next.Parent = parent
    end
end

function HotReloadClient.getSavedState() return savedState end

return HotReloadClient
