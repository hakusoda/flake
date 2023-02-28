--!strict
local root = script.Parent.Parent.Parent
local libraries = root.libraries

local Rodux = require(libraries.rodux)
-- make sure to replace "SET_EXAMPLE_VISIBLE" when you copy this!
return Rodux.makeActionCreator("SET_EXAMPLE_VISIBLE", function(visible: boolean)
	return { visible = visible }
end)