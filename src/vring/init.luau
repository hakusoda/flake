--!strict
local types = require(script.types)
local motorGroup = require(script.motorGroup)
local linearMotor = require(script.linearMotor)
export type motorGroup<G> = types.motorGroup<G>
export type linearMotor = types.linearMotor

return {
	motorGroup = motorGroup,
	linearMotor = linearMotor
}