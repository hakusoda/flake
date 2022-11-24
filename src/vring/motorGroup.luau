--!strict
local types = require(script.Parent.types)

local motorGroup = {} :: types.motorGroup<any>
motorGroup.__index = motorGroup

function motorGroup.new<G>(): types.motorGroup<G>
	local self: types.motorGroup<G> = setmetatable({}, motorGroup)
	self.motors = {}

	return self
end

function motorGroup:add<G>(name: string, motor: types.linearMotor): types.motorGroup<G>
	self.motors[name] = motor
	return self
end

function motorGroup:get<G>(name: string): types.linearMotor
	return self.motors[name]
end

function motorGroup:getValue<G>(name: string): number
	return self.motors[name]:getValue()
end

function motorGroup:step<G>(deltaTime: number): types.motorGroup<G>
	for _,motor in pairs(self.motors) do
		motor:step(deltaTime)
	end
	return self
end

function motorGroup:destroy<G>()
	for _,motor in pairs(self.motors) do
		motor:destroy()
	end
	self.motors = {}
end

return motorGroup