--!strict
local root = script.Parent.Parent
local actions = root.actions
local libraries = root.Parent.libraries

local llama = require(libraries.llama)
local Rodux = require(libraries.rodux)
local SetClientInfoVisible = require(actions.SetClientInfoVisible)

return Rodux.createReducer({
	clientInfoVisible = false
}, {
	[SetClientInfoVisible.name] = function(state, action)
		return llama.Dictionary.join(state, {
			clientInfoVisible = action.clientInfoVisible
		})
	end
})