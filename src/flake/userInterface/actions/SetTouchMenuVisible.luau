--!strict
local root = script.Parent.Parent.Parent
local libraries = root.libraries

local Rodux = require(libraries.rodux)
return Rodux.makeActionCreator("SET_TOUCH_MENU_VISIBLE", function(touchMenuVisible: boolean)
	return { touchMenuVisible = touchMenuVisible }
end)