--!strict
local root = script.Parent.Parent.Parent
local libraries = root.libraries

local Rodux = require(libraries.rodux)
return Rodux.makeActionCreator("SET_COMMAND_BAR_VISIBLE", function(commandBarVisible: boolean)
	return {
        commandBarVisible = commandBarVisible
    }
end)