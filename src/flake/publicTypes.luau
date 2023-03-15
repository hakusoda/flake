--!strict
local Fusion = require(script.Parent.libraries.Fusion.PubTypes)
export type flake = {
	emoji: string,
	player: Player,
	config: flakeConfig,
	version: string,
	serverClosed: boolean,

	cloud: cloud?,
	addons: addons,
	commands: commands,
	networking: networking,
	permissions: permissions,
	userInterface: userInterface,

	flakeFolder: Folder,

	closeServer: (self: flake) -> (),

	notifyPlayer: (self: flake, player: Player, title: string?, body: string, icon: string | notificationIcon | nil) -> (),

	sendAction: (self: flake, action: number, args: connectionArgs) -> (),
	sendPlayerAction: (self: flake, player: Player, action: number, args: connectionArgs) -> ()
}
export type flakeConfig = {
	cloud: {
		enabled: boolean,
		updateInterval: number
	},
	hidden: boolean,
	authorized: {number},
	importAddons: {number},
	disableAddons: {string},
	disableCommands: {string}
}

export type cloud = baseSystem & {
	
}

export type addons = baseSystem & {
	loaded: Fusion.Value<{baseAddon}>,

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
	id: string,
	level: Fusion.Value<number>,
	aliases: Fusion.Value<{string}>,
	context: Fusion.Value<commandContext>,
	arguments: Fusion.Value<{commandArgument}>,

	setLevel: (self: command, level: number) -> command,
	setAlias: (self: command, primary: string, secondary: string?) -> command,
	setSource: (self: command, source: baseAddon) -> command,
	setContext: (self: command, context: commandContext) -> command,
	
	getSource: (self: command) -> baseAddon?,
	
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
	gui: ScreenGui,
	playerGui: PlayerGui,
	components: Folder,
	touchMenuVisible: Fusion.Value<boolean>,
	commandBarVisible: Fusion.Value<boolean>,

	addAppComponent: (self: userInterface, component: appComponent) -> (),
	addTouchMenuItem: (self: userInterface, item: touchMenuItem) -> (),

	notify: (self: userInterface, title: string?, body: string, icon: string | notificationIcon | nil) -> (),
	createPrompt: (self: userInterface, options: promptOptions, windowOptions: windowOptions?) -> (),
	updateTouchMenu: (self: userInterface) -> ()
}
export type translatable = Fusion.CanBeState<string>
export type appComponent = (props: { flake: flake }) -> any
export type notification = {
	id: string,
	body: translatable,
	icon: notificationIcon,
	title: translatable?,
	exiting: Fusion.Value<boolean>,
	timeLength: number
}
export type notificationIcon = {
	image: string,
	color: Color3?
}
export type prompt = promptOptions & {
	id: string
}
export type promptOptions = {
	body: translatable,
	title: translatable,
	cancelButton: () -> ()?,
	confirmButton: () -> ()?
}

export type connectionArgs = {any}
export type networking = baseSystem & {
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
	name: string,
	emoji: string,

	onEvent: (self: baseSystem, name: string, callback: (...any) -> ()) -> ()
}

export type addonIcon = {
	main: string, -- recommended size: 128x128
	list: string -- recommended size: 80x80
}
export type addonAuthor = {
	name: string,
	icon: string -- recommended size: 128x128
}
export type baseAddon = {
	__index: baseAddon,

	id: string,
	name: string,
	base: baseAddon,
	icon: string | addonIcon,
	flake: flake,
	system: addons,
	version: string,
	authors: {string | addonAuthor},
	actions: { [string]: number },
	commands: Fusion.Value<command>,
	description: string,
	eventCallbacks: {any},

	new: (system: addons) -> baseAddon,

	-- not using "initialise" here for compatibility
	initialize: (self: baseAddon) -> (),

	onEvent: (self: baseAddon, name: string, callback: (...any) -> ()) -> (),
	emitEvent: (self: baseAddon, name: string, ...any) -> (),

	onAction: (self: baseAddon, player: Player?, action: number, args: { [number]: any }) -> (),
	sendAction: (self: baseAddon, action: number, args: connectionArgs) -> (),
	sendPlayerAction: (self: baseAddon, player: Player, action: number, args: connectionArgs) -> (),
	
	createCommand: (self: baseAddon, id: string) -> command,
	
	log: (self: baseAddon, ...any) -> ()
}
return ""