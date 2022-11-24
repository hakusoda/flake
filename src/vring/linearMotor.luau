--!strict
local types = require(script.Parent.types)
local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()

local linearMotor = {} :: types.linearMotor
linearMotor.__index = linearMotor

function linearMotor.new(initialValue: number?, velocity: number?): types.linearMotor
	local self: types.linearMotor = setmetatable({}, linearMotor)
	self.active = true

	self.value = initialValue or 0
	self.target = self.value
	self.value2 = self.value
	self.velocity = velocity or 1
	self.initial = {self.value, self.velocity}
	self.stepCallbacks = {}
	self.stepperCallbacks = {}
	self:log("initialized")

	return self :: any
end

function linearMotor:getValue(): number
	return self.value
end

function linearMotor:setValue(value: number): types.linearMotor
	self.value = value
	return self
end

function linearMotor:setTarget(value: number): types.linearMotor
	assert(self.active, "Motor is inactive/destroyed")
	if self.target ~= value then
		self.target = value
		self.value2 = self.value
	end

	return self
end

function linearMotor:setLength(length: number): types.linearMotor
	assert(self.active, "Motor is inactive/destroyed")
	self:setVelocity(math.abs(self.target - self.value2) / length)

	return self
end

function linearMotor:setVelocity(value: number): types.linearMotor
	self.velocity = value
	return self
end

function linearMotor:step(deltaTime: number): types.linearMotor
	assert(self.active, "Motor is inactive/destroyed")
	local position = self.value
	local velocity = self.velocity
	local goal = self.target

	local dPos = deltaTime * velocity

	local complete = dPos >= math.abs(goal - position)
	position += dPos * (goal > position and 1 or -1)

	if complete then
		position = goal
	end

	self.value = position
	for _,i in pairs(self.stepCallbacks) do
		i(self.value, self)
	end
	return self
end

function linearMotor:onStep(callback: (value: number, motor: types.linearMotor) -> ()): types.linearMotor
	assert(self.active, "Motor is inactive/destroyed")

	table.insert(self.stepCallbacks, callback)
	self:log("added onStep callback")

	return self
end

function linearMotor:onStepper(callback: (motor: types.linearMotor, value: number) -> ()): types.linearMotor
	assert(self.active, "Motor is inactive/destroyed")

	table.insert(self.stepperCallbacks, callback)
	self:log("added onStepper callback")

	return self
end

function linearMotor:connectStepper(signal: RBXScriptSignal): types.linearMotor
	assert(self.active, "Motor is inactive/destroyed")

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

function linearMotor:reset(): types.linearMotor
	assert(self.active, "Motor is inactive/destroyed")

	local value, velocity = self.initial[1], self.initial[2]
	self.value = value
	self.target = value
	self.velocity = velocity
	self:log("reset self to initial values")

	return self
end

function linearMotor:destroy()
	assert(self.active, "Motor is inactive/destroyed")

	if self.stepper then
		self.stepper:Disconnect()
		self.stepper = nil
	end
	self.value = 0
	self.target = 0
	self.value2 = 0
	self.initial = {}
	self.velocity = 0
	self.stepCallbacks = {}
	self.stepperCallbacks = {}

	self.active = false
	self:log("destroyed")
end

function linearMotor:log(text: string)
	if isStudio then
		warn("[vring:linearMotor]:", text)
	end
end

return linearMotor