--[[
	This is a prototype module that helps encode strong runtime type checks for
	functions.

	It's used in a couple different functions, as well as in ApiSpec to define
	the correct arguments for use in RemoteEvent objects.

	Typer is a prototype and won't make it into an official library in its
	current form.

	Check out "t" by Osyris for a more fleshed out approach:

		https://github.com/osyrisrblx/t
]] local Typer
= {}

local IS_SCHEMA = newproxy(true)

local function makeSchema(name, fn)
	local check = {
		[IS_SCHEMA] = true,
		name = name,
		validate = fn,
	}

	setmetatable(check, { __call = function(_, ...)
		return fn(...)
	end })

	return check
end

function Typer.args(...)
	local argsSchema = { ... }

	return function(...)
		if select('#', ...) > #argsSchema then
			local message =
				('Too many arguments passed in. Expected %d arguments or fewer, got %d'):format(
					#argsSchema,
					select('#', ...)
				)
			error(message, 3)
		end

		for index, arg in ipairs(argsSchema) do
			local argName = arg[1]
			local argSchema = arg[2]
			local value = select(index, ...)

			local success, err = argSchema.validate(value)

			if not success then
				local message =
					('Bad argument %s (#%d), expected %s, but %s'):format(
						argName,
						index,
						argSchema.name,
						err
					)
				error(message, 3)
			end
		end
	end
end

function Typer.instance(expectedInstanceClass)
	assert(typeof(expectedInstanceClass) == 'string', 'expectedInstanceClass must be a string')

	local name = ('Instance(%s)'):format(expectedInstanceClass)

	return makeSchema(name, function(value)
		local actualType = typeof(value)

		if actualType ~= 'Instance' then
			local message = ('got value of type %s'):format(actualType)

			return false, message
		end

		if value:IsA(expectedInstanceClass) then
			return true
		else
			local message = ('got instance of class %s'):format(value.ClassName)

			return false, message
		end
	end)
end

function Typer.type(expectedType)
	assert(typeof(expectedType) == 'string', 'expectedType must be a string')

	return makeSchema(expectedType, function(value)
		local actualType = typeof(value)
		if actualType == expectedType then
			return true
		else
			local message = ('got value of type %s'):format(actualType)

			return false, message
		end
	end)
end

function Typer.any()
	return makeSchema('any', function(value)
		return true
	end)
end

function Typer.optional(innerCheck)
	assert(typeof(innerCheck) == 'table' and innerCheck[IS_SCHEMA])

	local name = ('optional(%s)'):format(innerCheck.name)

	return makeSchema(name, function(value)
		if value == nil then
			return true
		else
			return innerCheck(value)
		end
	end)
end

function Typer.listOf(innerCheck)
	assert(typeof(innerCheck) == 'table' and innerCheck[IS_SCHEMA])

	local name = ('list(%s)'):format(innerCheck.name)

	return makeSchema(name, function(list)
		local actualType = typeof(list)

		if actualType ~= 'table' then
			return false, ('got value of type %s'):format(actualType)
		end

		for key, value in pairs(list) do
			local keyType = typeof(key)

			if keyType ~= 'number' then
				return false, ('got non-number key %s (of type %s)'):format(tostring(key), keyType)
			end

			local success, err = innerCheck(value)

			if not success then
				return false, ('had bad value at key %d, %s'):format(key, err)
			end
		end

		return true
	end)
end

function Typer.mapOf(keyCheck, valueCheck)
	assert(typeof(keyCheck) == 'table' and keyCheck[IS_SCHEMA])
	assert(typeof(valueCheck) == 'table' and valueCheck[IS_SCHEMA])

	local name = ('map(%s, %s)'):format(keyCheck.name, valueCheck.name)

	local tableTypeCheck = Typer.type('table')

	return makeSchema(name, function(map)
		local mapOk, mapErr = tableTypeCheck(map)

		if not mapOk then
			return false, mapErr
		end

		for key, value in pairs(map) do
			local keyOk, keyErr = keyCheck(key)

			if not keyOk then
				return false, ('had bad key %s: %s'):format(tostring(key), keyErr)
			end

			local valueOk, valueErr = keyCheck(value)

			if not valueOk then
				return false, ('had bad value %s at key %s'):format(
					tostring(value),
					tostring(key),
					valueErr
				)
			end
		end

		return true
	end)
end

function Typer.object(name, shape)
	assert(typeof(shape) == 'table' and not shape[IS_SCHEMA])

	return makeSchema(name, function(object)
		for key, valueCheck in pairs(shape) do
			local value = object[key]

			local ok, err = valueCheck(value)

			if not ok then
				return false, ('had bad key %s: %s'):format(tostring(key), err)
			end
		end

		for key, value in pairs(object) do
			if shape[key] == nil then
				return false, ('had unknown key %s with value %s'):format(
					tostring(key),
					tostring(value)
				)
			end
		end

		return true
	end)
end

return Typer