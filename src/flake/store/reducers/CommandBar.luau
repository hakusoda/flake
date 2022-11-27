--!strict
local root = script.Parent.Parent
local actions = root.actions
local libraries = root.Parent.libraries

local Cryo = require(libraries.llama)
local Rodux = require(libraries.rodux)
local SetCommandBarVisible = require(actions.SetCommandBarVisible)
local SetCommandBarCommands = require(actions.SetCommandBarCommands)

return Rodux.createReducer({
	visible = false,
	commands = {}
}, {
	[SetCommandBarVisible.name] = function(state, action)
		return Cryo.Dictionary.join(state, {
			visible = action.commandBarVisible
		})
	end,

	[SetCommandBarCommands.name] = function(state, action)
		return Cryo.Dictionary.join(state, {
			commands = action.commands
		})
	end
})