local subreducers = {}

-- Bundling up all of our submodules makes it convenient to adjust reducers.
for _, child in ipairs(script:GetChildren()) do
    if child:IsA("ModuleScript") then
        subreducers[child.Name] = require(child)
    end
end

return subreducers
