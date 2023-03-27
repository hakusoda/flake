--!strict
local root = script.Parent
local libraries = root.libraries

local Fusion = require(libraries.Fusion.PubTypes)
local supabase = require(libraries.supabase.types)
local publicTypes = require(root.publicTypes)

export type auditLog = publicTypes.auditLog
export type auditLogAction = publicTypes.auditLogAction
export type flake = {
	__index: flake,
	emoji: string,
	player: Player,
	config: flakeConfig,
	version: string,
	auditLogs: Fusion.Value<{auditLog}>,
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
	
	addAuditLog: (self: flake, target: string, player: Player?, action: auditLogAction) -> (),
	
	closeServer: (self: flake) -> (),
	
	kickPlayer: (self: flake, target: Player, reason: string?, executor: Player?) -> (),
	notifyPlayer: (self: flake, player: Player, title: string?, body: string, icon: string | notificationIcon | nil) -> (),

	sendAction: (self: flake, action: number, args: connectionArgs) -> (),
	sendPlayerAction: (self: flake, player: Player, action: number, args: connectionArgs) -> (),

	log: (self: flake, ...any) -> ()
}
export type flakeConfig = publicTypes.flakeConfig
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

export type commandSuggestion = {
	text: string,
	index: number,
	command: command
}
export type commands = baseSystem & {
	commands: Fusion.Value<{command}>,
	
	getAll: (self: commands) -> {command},
	getById: (self: commands, id: string) -> command?,
	getByAlias: (self: commands, alias: string) -> command?,

	create: (self: commands, id: string) -> command,
	
	getCommand: (self: commands, input: string) -> (command?, {commandSuggestion}),
	
	processCommandString: (self: commands, executor: Player, text: string, ignoreLevel: boolean?) -> (),
	processArgument: (self: commands, player: Player, argument: commandArgument, text: {string}, pos: number) -> (),

	execute: (self: commands, command: command, player: Player, args: {any}, sourceString: string?) -> ()
}

export type commandContext = publicTypes.commandContext
export type commandArgumentType = publicTypes.commandArgumentType
export type commandArgumentMatch = publicTypes.commandArgumentMatch
export type commandArgument = publicTypes.commandArgument
export type commandArgumentSuggestor = publicTypes.commandArgumentSuggestor
export type commandArgumentSuggestion = publicTypes.commandArgumentSuggestion
export type command = {
	__index: command,

	id: string,
	level: Fusion.Value<number>,
	system: commands,
	source: baseAddon?,
	aliases: Fusion.Value<{string}>,
	context: Fusion.Value<commandContext>,
	shouldLog: Fusion.Value<boolean>,
	arguments: Fusion.Value<{commandArgument}>,
	callbacks: {(self: command, ...any) -> ()},
	chatCommand: TextChatCommand?,

	new: (id: string, system: commands) -> command,

	setLevel: (self: command, level: number) -> command,
	setAlias: (self: command, primary: string, secondary: string?) -> command,
	setSource: (self: command, source: baseAddon) -> command,
	setContext: (self: command, context: commandContext) -> command,
	setShouldLog: (self: command, value: boolean) -> command,
	
	getSource: (self: command) -> baseAddon?,
	getSuggestions: (self: command, input: string, cursor: number) -> ({commandArgumentSuggestion}, { [string]: Fusion.CanBeState<string> }),

	isInContext: (self: command) -> boolean,

	addArgument: (self: command, id: string, type: commandArgumentType, match: commandArgumentMatch?, suggestor: commandArgumentSuggestor?) -> command,

	onCallback: (self: command, callback: (self: command, executor: Player, ...any) -> ()) -> command,

	hasPermission: (self: command, player: Player) -> boolean
}

export type windowOptions = publicTypes.windowOptions
export type touchMenuItem = publicTypes.touchMenuItem
export type userInterface = baseSystem & {
	gui: ScreenGui,
	prompts: Fusion.Value<{prompt}>,
	playerGui: PlayerGui,
	components: Folder,
	appComponents: Fusion.Value<{appComponent}>,
	notifications: Fusion.Value<{notification}>,
	touchMenuItems: Fusion.Value<{touchMenuItem}>,
	touchMenuVisible: Fusion.Value<boolean>,
	commandBarVisible: Fusion.Value<boolean>,

	addAppComponent: (self: userInterface, component: appComponent) -> (),
	addTouchMenuItem: (self: userInterface, item: touchMenuItem) -> (),

	notify: (self: userInterface, title: translatable?, body: translatable, icon: string | notificationIcon | nil) -> (),
	createPrompt: (self: userInterface, options: promptOptions, windowOptions: windowOptions?) -> (),
	updateTouchMenu: (self: userInterface) -> ()
}
export type translatable = publicTypes.translatable
export type appComponent = (props: { flake: flake }) -> any
export type notification = publicTypes.notification
export type notificationIcon = publicTypes.notificationIcon
export type prompt = publicTypes.prompt
export type promptOptions = publicTypes.promptOptions

export type connectionArgs = publicTypes.connectionArgs
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
	
	isPlayerSpecial: (self: permissions, player: Player) -> boolean,
	
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

export type addonIcon = publicTypes.addonIcon
export type addonAuthor = publicTypes.addonAuthor
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
	
	getIcon: (self: baseAddon, type: "main" | "list") -> string,
	
	onAction: (self: baseAddon, player: Player?, action: number, args: { [number]: any }) -> (),
	sendAction: (self: baseAddon, action: number, args: connectionArgs) -> (),
	sendPlayerAction: (self: baseAddon, player: Player, action: number, args: connectionArgs) -> (),
	
	createCommand: (self: baseAddon, id: string) -> command,
	
	log: (self: baseAddon, ...any) -> ()
}
return ""