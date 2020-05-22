local subreducers = {}

-- Bundle all of our submodules automatically.
for _, child in ipairs(script:GetChildren()) do
    if child:IsA("ModuleScript") then
        subreducers[child.Name] = require(child)
    end
end

return subreducers
