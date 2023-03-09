--!strict
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")

local root = script.Parent.Parent
local libraries = root.libraries

local types = require(root.types)
local llama = require(libraries.llama)
local Fusion = require(libraries.Fusion)

local isServer = RunService:IsServer()
local isClient = RunService:IsClient()

local Value = Fusion.Value
local command: types.command = {} :: any
command.__index = command

function command.new(id: string, system: types.commands): types.command
	local self = setmetatable({}, command)
	self.id = id
	self.level = Value(0)
	self.match = "default"
	self.system = system
	self.context = Value("server")
	self.aliases = Value({"unknown"})
	self.arguments = Value({})

	self.callbacks = {}

	if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		if isServer then
			self.chatCommand = Instance.new("TextChatCommand")
			self.chatCommand.Name = self.id
			self.chatCommand.Parent = TextChatService
		else
			self.chatCommand = TextChatService:WaitForChild(self.id)
		end
	end

	return self :: any
end

function command:setLevel(level: number)
	self.level:set(level)
	return self
end

function command:setAlias(primary: string, secondary: string?)
	self.aliases:set({primary, secondary :: string})
	if self.chatCommand then
		self.chatCommand.PrimaryAlias = "/"..primary
		self.chatCommand.SecondaryAlias = secondary and "/"..secondary or ""
	end
	return self
end

function command:setContext(context: types.commandContext)
	self.context:set(context)
	return self
end

function command:isInContext(): boolean
	local context = self.context:get()
	if context == "both" or (isServer and context == "server") or (isClient and context == "client") then
		return true
	end

	return false
end

function command:addArgument(id: string, type: types.commandArgumentType, match: types.commandArgumentMatch?)
	local list = self.arguments
	list:set(llama.List.join(list:get(), {{
		id = id,
		type = type,
		match = match or "default"
	}}))
	
	return self
end

function command:onCallback(callback)
	table.insert(self.callbacks, callback)
	return self
end

function command:hasPermission(player: Player)
	return self.system.flake.permissions:getPlayerLevel(player) >= self.level:get()
end

return command