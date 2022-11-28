--!strict
local root = script.Parent.Parent
local actions = root.actions
local libraries = root.Parent.libraries

local llama = require(libraries.llama)
local Rodux = require(libraries.rodux)
local SetClientStatsVisible = require(actions.SetClientStatsVisible)

return Rodux.createReducer({
	clientStatsVisible = false
}, {
	[SetClientStatsVisible.name] = function(state, action)
		return llama.Dictionary.join(state, {
			clientStatsVisible = action.clientStatsVisible
		})
	end
})