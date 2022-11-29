--!strict
local root = script.Parent.Parent.Parent
local libraries = root.libraries

local Rodux = require(libraries.rodux)
return Rodux.makeActionCreator("ADD_TOUCH_MENU_ITEM", function(item)
	return { item = item }
end)