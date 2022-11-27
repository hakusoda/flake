--!strict
local root = script.Parent.Parent.Parent
local libraries = root.libraries

local Rodux = require(libraries.rodux)
return Rodux.makeActionCreator("REMOVE_NOTIFICATION", function(notificationId: string)
	return { notificationId = notificationId }
end)