local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local reloadScheduled = false

local reloadBindable = Instance.new("RemoteFunction")
reloadBindable.Name = "HotReloaded"
reloadBindable.Parent = ReplicatedStorage

local function listenToChangesRecursive(root, connections, callback)
    table.insert(connections, (root.Changed:Connect(callback)))

    for _, child in ipairs(root:GetChildren()) do
        listenToChangesRecursive(child, connections, callback)
    end
end

local function replace(object)
    -- Do you ever get that feeling that everything in your house has been
    -- replaced by an exact replica?

    local new = object:Clone()
    new.Parent = object.Parent
    object:Destroy()
end

local savedState = nil

local HotReloadServer = {}

function HotReloadServer.start(options)
    local objectsToWatch = options.watch
    local beforeUnload = options.beforeUnload
    local afterReload = options.afterReload

    local connections = {}

    local function changeCallback()
        if reloadScheduled then return end

        print("Scheduled hot reload!")

        reloadScheduled = true

        for _, connection in ipairs(connections) do
            connection:Disconnect()
        end

        wait(0.1)

        savedState = beforeUnload()

        for _, object in ipairs(objectsToWatch) do replace(object) end

        wait(0.1)

        for _, player in ipairs(Players:GetPlayers()) do
            reloadBindable:InvokeClient(player)
        end

        afterReload()

        reloadScheduled = false
    end

    spawn(function()
        for _, object in ipairs(objectsToWatch) do
            table.insert(connections,
                         (object.DescendantAdded:Connect(changeCallback)))

            listenToChangesRecursive(object, connections, changeCallback)
        end
    end)
end

function HotReloadServer.getSavedState() return savedState end

return HotReloadServer
