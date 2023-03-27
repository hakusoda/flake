--!strict
local RunService = game:GetService("RunService")

local root = script.Parent.Parent
local libraries = root.libraries

local util = require(root.util)
local types = require(root.types)
local Fusion = require(libraries.Fusion)

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
	self.base = baseAddon
	self.flake = system.flake
	self.system = system
	self.commands = Fusion.Value({})
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
	table.insert(self.eventCallbacks, {name, callback :: any})
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

function baseAddon:getIcon(type: "main" | "list")
	local icon = self.icon
	if typeof(icon) == "string" then
		return icon
	else
		return icon[type]
	end
end

function baseAddon:sendAction(action: number, args: types.connectionArgs)
	return self.flake.networking:sendAction(2, {self.id, action, args})
end

function baseAddon:sendPlayerAction(player: Player, action: number, args: types.connectionArgs)
	return self.flake.networking:sendPlayerAction(player, 2, {self.id, action, args})
end

function baseAddon:createCommand(id: string)
	local command = self.flake.commands:create(id):setSource(self)
	local commands = self.commands
	commands:set(util.concat(commands:get(false), {command}))
	
	return command
end

function baseAddon:log(...)
	warn(`[flake:addons:{self.id}]:`, ...)
end

return baseAddon