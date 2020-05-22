local Print = {}

local indent = "   "

function Print.prettyPrint(value, indentLevel)
    indentLevel = indentLevel or 0
    local output = {}

    if typeof(value) == "table" then
        table.insert(output, "{\n")

        for key, value in pairs(value) do
            table.insert(output, indent:rep(indentLevel + 1))
            table.insert(output, tostring(key))
            table.insert(output, " = ")

            table.insert(output, Print.prettyPrint(value, indentLevel + 1))
            table.insert(output, "\n")
        end

        table.insert(output, indent:rep(indentLevel))
        table.insert(output, "}")
    elseif typeof(value) == "string" then
        table.insert(output, string.format("%q", value))
        table.insert(output, " (string)")
    else
        table.insert(output, tostring(value))
        table.insert(output, " (")
        table.insert(output, typeof(value))
        table.insert(output, ")")
    end

    return table.concat(output, "")
end

return Print
