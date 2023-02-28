--!strict
local root = script.Parent.Parent.Parent
local libraries = root.libraries
local components = script.Parent

local types = require(root.types)
local Fusion = require(libraries.Fusion)
local Prompt = require(components.Prompt)

local Computed, ForValues = Fusion.Computed, Fusion.ForValues
export type AppProps = {
	flake: types.flake
}
return function(props: AppProps)
	local flake = props.flake
	return {
		Computed(function()
			local data = flake.userInterface.prompts:get()[1]
			if data then
				return Prompt {
					data = data,
					flake = flake
				}
			end

			return nil :: any
		end, Fusion.cleanup) :: any,

		ForValues(flake.userInterface.appComponents, function(component)
			return component { flake = flake }
		end, Fusion.cleanup) :: any
	}
end