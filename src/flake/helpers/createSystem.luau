--!strict
local root = script.Parent.Parent
local types = require(root.types)
local baseSystem = require(root.classes.baseSystem)
return function<T>(name: string, emoji: string): (T, (flake: types.flake) -> T)
	local system: types.baseSystem & T = setmetatable({}, baseSystem) :: any
	system.__index = system
	system.name = name
	system.emoji = emoji
	
	return system, function(flake: types.flake)
		return setmetatable(baseSystem.new(flake), system) :: any
	end
end