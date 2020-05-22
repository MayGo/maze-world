--[[
	Defines utilities for working with 'dictionary-like' tables.

	This file, along with None.lua, come from a library we'll be releasing soon
	called Cryo. It has a set of utilities, like this one, to help make working
	with immutable data structures easier.

	Dictionaries can be indexed by any value, but don't have the ordering
	expectations that lists have.
]] local None = require(script.Parent.None)

local Dict = {}

--[[
	Combine a number of dictionary-like tables into a new table.

	Keys specified in later tables will overwrite keys in previous tables.

	Use `None` as a value to remove a key. This is necessary because
	Lua does not distinguish between a value not being present in a table and a
	value being `nil`.
]]

function Dict.join(...)
    local new = {}

    for i = 1, select("#", ...) do
        local source = select(i, ...)

        for key, value in pairs(source) do
            if value == None then
                new[key] = nil
            else
                new[key] = value
            end
        end
    end

    return new
end

return Dict
