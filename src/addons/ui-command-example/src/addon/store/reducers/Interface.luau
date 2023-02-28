--!strict
local root = script.Parent.Parent
local actions = root.actions
local libraries = root.Parent.libraries

local llama = require(libraries.llama)
local Rodux = require(libraries.rodux)
local SetExampleVisible = require(actions.SetExampleVisible)

return Rodux.createReducer({
	exampleVisible = false
}, {
	[SetExampleVisible.name] = function(state, action)
		return llama.Dictionary.join(state, {
			exampleVisible = action.visible
		})
	end
})