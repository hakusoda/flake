--!strict
local root = script.Parent.Parent
local reducers = script.Parent
local libraries = root.Parent.libraries

local Rodux = require(libraries.rodux)
local Interface = require(reducers.Interface)
local Notifications = require(reducers.Notifications)

return Rodux.combineReducers({
	interface = Interface,
	notifications = Notifications
})