--!strict
local root = script.Parent.Parent.Parent
local libraries = root.libraries

local Rodux = require(libraries.rodux)
return Rodux.makeActionCreator("SET_CLIENT_STATS_VISIBLE", function(clientStatsVisible: boolean)
	return { clientStatsVisible = clientStatsVisible }
end)