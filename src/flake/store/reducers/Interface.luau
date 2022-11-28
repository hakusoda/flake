--!strict
local root = script.Parent.Parent
local actions = root.actions
local libraries = root.Parent.libraries

local Cryo = require(libraries.llama)
local Rodux = require(libraries.rodux)
local EndPrompt = require(actions.EndPrompt)
local CreatePrompt = require(actions.CreatePrompt)
local AddAppComponent = require(actions.AddAppComponent)
local SetFlakeInfoVisible = require(actions.SetFlakeInfoVisible)
local SetTouchMenuVisible = require(actions.SetTouchMenuVisible)
local SetCommandListVisible = require(actions.SetCommandListVisible)

return Rodux.createReducer({
	prompts = {},
	infoVisible = false,
    appComponents = {},
	touchMenuVisible = false,
	commandListVisible = false
}, {
	[CreatePrompt.name] = function(state, action)
		return Cryo.Dictionary.join(state, {
			prompts = Cryo.List.join(state.prompts, { action.data })
		})
	end,
	[EndPrompt.name] = function(state, action)
		return Cryo.Dictionary.join(state, {
			prompts = Cryo.List.filter(state.prompts, function(item)
				return item.id ~= action.promptId
			end)
		})
	end,

	[SetFlakeInfoVisible.name] = function(state, action)
		return Cryo.Dictionary.join(state, {
			infoVisible = action.infoVisible
		})
	end,

    [AddAppComponent.name] = function(state, action)
        return Cryo.Dictionary.join(state, {
			appComponents = Cryo.List.join(state.appComponents, {action.component})
		})
    end,

	[SetTouchMenuVisible.name] = function(state, action)
		return Cryo.Dictionary.join(state, {
			touchMenuVisible = action.touchMenuVisible
		})
	end,

	[SetCommandListVisible.name] = function(state, action)
		return Cryo.Dictionary.join(state, {
			commandListVisible = action.commandListVisible
		})
	end
})