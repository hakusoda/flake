--!strict
local types = require(script.Parent.types)
local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()

local motorGroup = {} :: types.motorGroup<any>
motorGroup.__index = motorGroup

function motorGroup.new<G>(): types.motorGroup<G>
	local self: types.motorGroup<G> = setmetatable({}, motorGroup)
	self.motors = {}
    self.stepCallbacks = {}
	self.stepperCallbacks = {}
    self:log("initialized")

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

function motorGroup:getValues<G>(): { [G]: types.linearMotor }
    local mapped = {}
    for name, motor in pairs(self.motors) do
        mapped[name] = motor:getValue()
    end

    return mapped
end

function motorGroup:step<G>(deltaTime: number): types.motorGroup<G>
	for _,motor in pairs(self.motors) do
		motor:step(deltaTime)
	end
    for _,i in pairs(self.stepCallbacks) do
		i(self:getValues(), self)
	end
	return self
end

function motorGroup:onStep(callback: (value: number, motor: types.linearMotor) -> ()): types.linearMotor
	table.insert(self.stepCallbacks, callback)
	self:log("added onStep callback")

	return self
end

function motorGroup:onStepper(callback: (motor: types.linearMotor, value: number) -> ()): types.linearMotor
	table.insert(self.stepperCallbacks, callback)
	self:log("added onStepper callback")

	return self
end

function motorGroup:connectStepper(signal: RBXScriptSignal): types.linearMotor
	self.stepper = signal:Connect(function(num1: number, num2: number?)
		local deltaTime = num2 or num1
		for _,i in pairs(self.stepperCallbacks) do
			i(self, deltaTime)
		end
		self:step(deltaTime)
	end)
	self:log("connected stepper")

	return self
end

function motorGroup:destroy<G>()
	for _,motor in pairs(self.motors) do
		motor:destroy()
	end
	self.motors = {}
    self:log("destroyed")
end

function motorGroup:log(text: string)
	if isStudio then
		warn("[vring:motorGroup]:", text)
	end
end

return motorGroup