--!strict
local root = script.Parent.Parent.Parent
local libraries = root.libraries

local Rodux = require(libraries.rodux)
return Rodux.makeActionCreator("SET_FLAKE_INFO_VISIBLE", function(infoVisible: boolean)
	return {
        infoVisible = infoVisible
    }
end)