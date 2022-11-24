--!strict
local root = script.Parent.Parent.Parent
local actions = script.Parent.Parent.actions
local libraries = root.libraries

local Cryo = require(libraries.llama)
local Rodux = require(libraries.rodux)
local AddNotification = require(actions.AddNotification)
local RemoveNotification = require(actions.RemoveNotification)

return Rodux.createReducer({}, {
	[AddNotification.name] = function(state, action)
		return Cryo.List.join(state, {
			action.data
		})
	end,
	[RemoveNotification.name] = function(state, action)
		return Cryo.List.filter(state, function(item)
			return item.id ~= action.notificationId
		end)
	end
})