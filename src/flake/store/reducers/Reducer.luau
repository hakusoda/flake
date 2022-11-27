--!strict
local root = script.Parent.Parent
local reducers = script.Parent
local libraries = root.Parent.libraries

local Rodux = require(libraries.rodux)
local Interface = require(reducers.Interface)
local CommandBar = require(reducers.CommandBar)
local Notifications = require(reducers.Notifications)

return Rodux.combineReducers({
	interface = Interface,
	commandBar = CommandBar,
	notifications = Notifications
})