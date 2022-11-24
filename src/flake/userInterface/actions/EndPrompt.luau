--!strict
local root = script.Parent.Parent.Parent
local libraries = root.libraries

local Rodux = require(libraries.rodux)
return Rodux.makeActionCreator("END_PROMPT", function(promptId: string)
	return { promptId = promptId }
end)