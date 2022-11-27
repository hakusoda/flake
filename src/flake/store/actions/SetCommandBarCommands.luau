--!strict
local root = script.Parent.Parent.Parent
local libraries = root.libraries

local Rodux = require(libraries.rodux)
return Rodux.makeActionCreator("SET_COMMAND_BAR_COMMANDS", function(commands)
	return { commands = commands }
end)