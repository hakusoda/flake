--!strict
local Fusion = require(script.Parent.libraries.Fusion)

export type flake = {
	__index: flake,
	emoji: string,
	player: Player,
	addons: addons,
	config: flakeConfig,
	version: string,
	commands: commands,
	libraries: Folder,
	connection: RemoteEvent,
	networking: networking,
	permissions: permissions,
	userInterface: userInterface,

	flakeFolder: Folder,

	new: () -> flake,

	initialize: (self: flake) -> (),
	addClientActor: (self: flake) -> (),

	notifyPlayer: (self: flake, player: Player, title: string?, body: string, icon: string | notificationIcon | nil) -> (),

	sendAction: (self: flake, action: number, args: connectionArgs) -> (),
	sendPlayerAction: (self: flake, player: Player, action: number, args: connectionArgs) -> (),

	log: (self: flake, ...any) -> ()
}
export type flakeConfig = {
	hidden: boolean,
	authorized: {number},
	importAddons: {number}
}

export type addons = baseSystem & {
	__index: addons,

	loaded: Fusion.Value<{baseAddon}>,
	addonFolder: Folder,
	
	getById: (self: addons, id: string) -> baseAddon?,
	loadAddon: (self: addons, module: Instance) -> (),
	loadAddons: (self: addons) -> ()
}

export type commands = baseSystem & {
	commands: Fusion.Value<{command}>,

	getById: (self: commands, id: string) -> command?,
	getByAlias: (self: commands, alias: string) -> command?,

	create: (self: commands, id: string) -> command,

	processCommand: (self: commands, command: command, executor: Player, arguments: any) -> (),
	processCommandString: (self: commands, executor: Player, text: string, ignoreLevel: boolean?) -> (),
	processArgument: (self: commands, player: Player, argument: commandArgument, text: {string}, pos: number) -> (),

	execute: (self: commands, command: command, player: Player, args: {any}) -> ()
}

export type commandContext = "server" | "client" | "both"
export type commandArgumentType = "string" | "strings" | "number" | "players"
export type commandArgumentMatch = "default" | "rest"
export type commandArgument = {
	id: string,
	type: commandArgumentType,
	match: commandArgumentMatch
}
export type command = {
	__index: command,

	id: string,
	level: Fusion.Value<number>,
	system: commands,
	aliases: Fusion.Value<{string}>,
	context: Fusion.Value<commandContext>,
	arguments: Fusion.Value<{commandArgument}>,
	callbacks: {(self: command, ...any) -> ()},
	chatCommand: TextChatCommand?,

	new: (id: string, system: commands) -> command,

	setLevel: (self: command, level: number) -> command,
	setAlias: (self: command, primary: string, secondary: string?) -> command,
	setContext: (self: command, context: commandContext) -> command,

	isInContext: (self: command) -> boolean,

	addArgument: (self: command, id: string, type: commandArgumentType, match: commandArgumentMatch?) -> command,

	onCallback: (self: command, callback: (self: command, executor: Player, ...any) -> ()) -> command,

	hasPermission: (self: command, player: Player) -> boolean
}

export type windowOptions = {
	title: string?
}
export type touchMenuItem = {
	icon: string,
	onClick: () -> ()
}
export type userInterface = baseSystem & {
	prompts: Fusion.Value<{prompt}>,
	components: Folder,
	appComponents: Fusion.Value<{appComponent}>,
	notifications: Fusion.Value<{notification}>,
	touchMenuItems: Fusion.Value<{touchMenuItem}>,
	touchMenuVisible: Fusion.Value<boolean>,
	commandBarVisible: Fusion.Value<boolean>,

	addAppComponent: (self: userInterface, component: appComponent) -> (),
	addTouchMenuItem: (self: userInterface, item: touchMenuItem) -> (),

	notify: (self: userInterface, title: string?, body: string, icon: string | notificationIcon | nil) -> (),
	createPrompt: (self: userInterface, options: promptOptions, windowOptions: windowOptions?) -> (),
	updateTouchMenu: (self: userInterface) -> ()
}
export type appComponent = (props: { flake: flake }) -> any
export type notification = {
	id: string,
	body: string,
	icon: notificationIcon,
	title: string?,
	endTime: number
}
export type notificationIcon = {
	image: string,
	color: Color3?
}
export type prompt = promptOptions & {
	id: string
}
export type promptOptions = {
	body: string,
	title: string,
	cancelButton: () -> ()?,
	confirmButton: () -> ()?
}

export type connectionArgs = {any}
export type networking = baseSystem & {
	key: string,
	connection: RemoteEvent,
	requestKey: RemoteFunction,

	sendAction: (self: networking, action: number, args: connectionArgs) -> (),
	sendPlayerAction: (self: networking, player: Player, action: number, args: connectionArgs) -> (),

	onAction: (self: networking, player: Player?, action: number, args: { [number]: any }) -> ()
}

export type permissions = baseSystem & {
	attribute: string,

	getLevel: (self: permissions) -> number,
	getPlayerLevel: (self: permissions, player: Player) -> number,

	setPlayerLevel: (self: permissions, player: Player, level: number) -> ()
}

export type baseSystem = {
	__index: baseSystem,

	name: string,
	flake: flake,
	emoji: string,
	eventCallbacks: {any},

	new: (flake: flake) -> baseSystem,

	initialize: (self: baseSystem) -> (),

	emitEvent: <T>(self: T, name: string, ...any) -> (),
	onEvent: <T>(self: T, name: string, callback: (...any) -> ()) -> (),

	log: <T>(self: T, ...any) -> ()
}
export type baseAddon = {
	__index: baseAddon,

	id: string,
	name: string,
	icon: string,
	flake: flake,
	system: addons,
	version: string,
	authors: {string},
	actions: { [string]: number },
	description: string,
	eventCallbacks: {any},

	new: (system: addons) -> baseAddon,
	initialize: (self: baseAddon) -> (),

	emitEvent: (self: baseAddon, name: string, ...any) -> (),
	onEvent: (self: baseAddon, name: string, callback: (...any) -> ()) -> (),

	onAction: (self: baseAddon, player: Player?, action: number, args: { [number]: any }) -> (),
	sendAction: <T>(self: T, action: number, args: connectionArgs) -> (),
	sendPlayerAction: <T>(self: T, player: Player, action: number, args: connectionArgs) -> (),

	log: (self: baseAddon, ...any) -> ()
}
return ""