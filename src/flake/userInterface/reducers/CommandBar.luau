--!strict
local root = script.Parent.Parent.Parent
local actions = script.Parent.Parent.actions
local libraries = root.libraries

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