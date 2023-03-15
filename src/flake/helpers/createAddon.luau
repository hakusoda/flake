--!strict
local root = script.Parent.Parent
local types = require(root.types)
local baseAddon = require(root.classes.baseAddon)
return function<T>(id: string, name: string, version: string): (T, (addons: types.addons) -> T)
	local addon: types.baseAddon & T = setmetatable({}, baseAddon) :: any
	addon.__index = addon
	addon.id = id
	addon.name = name
	addon.version = version
	
	return addon, function(addons: types.addons)
		return setmetatable(baseAddon.new(addons), addon) :: any
	end
end