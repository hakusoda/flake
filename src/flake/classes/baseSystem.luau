--!strict
-- this is the base of all systems, not much to explain here :(
local RunService = game:GetService("RunService")

local root = script.Parent.Parent
local types = require(root.types)

local isStudio = RunService:IsStudio()

local baseSystem: types.baseSystem = {} :: any
baseSystem.__index = baseSystem
baseSystem.name = "baseSystem"
baseSystem.emoji = "ℹ️"

function baseSystem.new(flake: types.flake): types.baseSystem
	local self: types.baseSystem = setmetatable({}, baseSystem) :: any
	self.flake = flake
	self.eventCallbacks = {}

	return self
end

function baseSystem:initialise()
	
end

function baseSystem:emitEvent(name: string, ...)
	for _,call in self.eventCallbacks do
		if call[1] == name then
			call[2](...)
		end
	end
	if isStudio then
		self:log("emitted", name, "event")
	end
end

function baseSystem:onEvent(name: string, callback)
	table.insert(self.eventCallbacks, {name, callback :: any})
end

function baseSystem:log(...)
	warn(self.emoji, "[flake:"..self.name.."]:", ...)
end

return baseSystem