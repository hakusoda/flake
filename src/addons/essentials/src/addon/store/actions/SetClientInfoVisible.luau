--!strict
local root = script.Parent.Parent.Parent
local libraries = root.libraries

local Rodux = require(libraries.rodux)
return Rodux.makeActionCreator("SET_CLIENT_INFO_VISIBLE", function(clientInfoVisible: boolean)
	return { clientInfoVisible = clientInfoVisible }
end)