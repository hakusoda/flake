--!strict
local libraries = script.Parent.Parent.Parent.libraries
local components = script.Parent

local llama = require(libraries.llama)
local Roact = require(libraries["roact-compat"])
local Prompt = require(components.Prompt)
local TouchMenu = require(components.TouchMenu)
local FlakeInfo = require(components.FlakeInfo)
local RoactRodux = require(libraries["roact-rodux"])
local CommandBar = require(components.CommandBar)
local CommandList = require(components.CommandList)
local Notifications = require(components.Notifications)

return RoactRodux.connect(function(state)
	return {
        extra = state.interface.appComponents,
		prompts = state.interface.prompts
	}
end)(function(props)
    return Roact.createFragment({
		Roact.createElement(TouchMenu),
		Roact.createElement(CommandBar),
		Roact.createElement(Notifications),

		Roact.createElement(CommandList),
		Roact.createElement(FlakeInfo),

		Roact.createElement(Prompt, {
			data = props.prompts[1]
		}),

        table.unpack(llama.List.map(props.extra, function(component)
            return Roact.createElement(component)
        end))
	})
end)