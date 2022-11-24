--!strict
local root = script.Parent.Parent.Parent
local libraries = root.libraries

local Rodux = require(libraries.rodux)
return Rodux.makeActionCreator("ADD_NOTIFICATION", function(data)
	return { data = data }
end)