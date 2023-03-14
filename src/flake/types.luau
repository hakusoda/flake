--!strict
local libraries = script.Parent.libraries

local Fusion = require(libraries.Fusion.PubTypes)
local supabase = require(libraries.supabase.types)

export type flake = {
	__index: flake,
	emoji: string,
	player: Player,
	config: flakeConfig,
	version: string,
	libraries: Folder,
	connection: RemoteEvent,
	serverClosed: boolean,
	
	cloud: cloud?,
	addons: addons,
	commands: commands,
	networking: networking,
	permissions: permissions,
	userInterface: userInterface,

	flakeFolder: Folder,

	startFlake: () -> (),

	initialise: (self: flake) -> (),
	addClientLoader: (self: flake) -> (),
	
	closeServer: (self: flake) -> (),

	notifyPlayer: (self: flake, player: Player, title: string?, body: string, icon: string | notificationIcon | nil) -> (),

	sendAction: (self: flake, action: number, args: connectionArgs) -> (),
	sendPlayerAction: (self: flake, player: Player, action: number, args: connectionArgs) -> (),

	log: (self: flake, ...any) -> ()
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
export type cloudServerConfig = {
	accessKey: string
}

export type cloud = baseSystem & {
	__index: cloud,
	
	restUrl: string,
	config2: cloudServerConfig,
	supabase: supabase.supabase,
	serverCloudId: number,
	
	request: <T>(self: cloud, path: string, method: 'GET' | 'POST'?, body: any?) -> T,
	updatePlayers: (self: cloud, list: {Player}) -> ()
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

	new: (flake: flake) -> any,
	build: (flake: flake, extend: any) -> baseSystem,

	initialise: (self: baseSystem) -> (),
	
	onEvent: (self: baseSystem, name: string, callback: (...any) -> ()) -> (),
	emitEvent: (self: baseSystem, name: string, ...any) -> (),

	log: (self: baseSystem, ...any) -> ()
}

export type addonIcon = {
	main: string, -- recommended size: 128x128
	list: string -- recommended size: 80x80
}
export type baseAddon = {
	__index: baseAddon,

	id: string,
	name: string,
	icon: string | addonIcon,
	flake: flake,
	system: addons,
	version: string,
	authors: {string | {
		name: string,
		icon: string -- recommended size: 128x128
	}},
	actions: { [string]: number },
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

	log: (self: baseAddon, ...any) -> ()
}
return ""