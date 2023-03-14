--!strict
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()

local baseAddon = {} :: types.baseAddon
baseAddon.__index = baseAddon
baseAddon.id = "baseAddon"
baseAddon.name = "Base Addon"
baseAddon.icon = {
	main = "rbxassetid://12782863561",
	list = "rbxassetid://12782864342"
}
baseAddon.authors = {"Anonymous"}
baseAddon.description = "placeholder"
baseAddon.version = "0.0.0"

function baseAddon.new(system: types.addons)
	local self = setmetatable({}, baseAddon)
	self.flake = system.flake
	self.system = system
	self.eventCallbacks = {}

	return self :: any
end

function baseAddon:initialize()
	error(self.id.." has not implemented initialize")
end

function baseAddon:emitEvent(name: string, ...)
	for _,call in self.eventCallbacks do
		if call[1] == name then
			call[2](...)
		end
	end
	self:log("emitted", name, "event")
end

function baseAddon:onEvent(name: string, callback)
	table.insert(self.eventCallbacks, {name, callback})
end

function baseAddon:onAction(player: Player?, action: number, args: types.connectionArgs)
	local actionName
	for name, value in self.actions do
		if action == value then
			actionName = name
		end
	end

	assert(actionName, "Action "..action.." not found")
	if isServer then
		assert(player, "Missing player argument")
		self:log("received action", actionName, "from", player.Name, "("..player.DisplayName..")")
	else
		self:log("received action", actionName, "from server")
	end
end

function baseAddon:sendAction(action: number, args: types.connectionArgs)
	return self.flake.networking:sendAction(2, {self.id, action, args})
end

function baseAddon:sendPlayerAction(player: Player, action: number, args: types.connectionArgs)
	return self.flake.networking:sendPlayerAction(player, 2, {self.id, action, args})
end

function baseAddon:log(...)
	warn("[flake:"..self.id.."]:", ...)
end

return baseAddon