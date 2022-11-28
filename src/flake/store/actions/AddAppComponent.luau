--!strict
local root = script.Parent.Parent.Parent
local libraries = root.libraries

local Rodux = require(libraries.rodux)
return Rodux.makeActionCreator("ADD_APP_COMPONENT", function(component)
	return { component = component }
end)