export type motorGroup<G> = {
    __index: motorGroup<G>,

	motors: { [string]: linearMotor },

	new: () -> motorGroup<G>,
	add: (self: motorGroup<G>, name: G, motor: linearMotor) -> motorGroup<G>,
	get: (self: motorGroup<G>, name: G) -> linearMotor,
	getValue: (self: motorGroup<G>, name: G) -> number,
	destroy: (self: motorGroup<G>) -> (),
	step: (self: motorGroup<G>, deltaTime: number) -> motorGroup<G>
}
export type linearMotor = {
    __index: linearMotor,

	value: number,
	target: number,
	value2: number,
	active: boolean,
	velocity: number,

	initial: { [number]: number },
	stepper: RBXScriptConnection?,
	stepCallbacks: { [number]: any },
	stepperCallbacks: { [number]: any },

	new: (initialValue: number?, velocity: number?) -> linearMotor,
	step: (self: linearMotor, deltaTime: number) -> linearMotor,
	reset: (self: linearMotor) -> linearMotor,
	onStep: (self: linearMotor, callback: (value: number, motor: linearMotor) -> ()) -> linearMotor,
	getValue: (self: linearMotor) -> number,
	setValue: (self: linearMotor, value: number) -> linearMotor,
	setTarget: (self: linearMotor, value: number) -> linearMotor,
	setLength: (self: linearMotor, length: number) -> linearMotor,
	onStepper: (self: linearMotor, callback: (motor: linearMotor, deltaTime: number) -> ()) -> linearMotor,
	setVelocity: (self: linearMotor, value: number) -> linearMotor,
	connectStepper: (self: linearMotor, signal: RBXScriptSignal) -> linearMotor,
	destroy: (self: linearMotor) -> (),
	log: (self: linearMotor, text: string) -> ()
}
return ""