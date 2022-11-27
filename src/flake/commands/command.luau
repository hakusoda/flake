--!strict
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")

local root = script.Parent.Parent
local types = require(root.types)

local isServer = RunService:IsServer()
local isClient = RunService:IsClient()

local command: types.command = {} :: any
command.__index = command

function command.new(id: string, system: types.commands): types.command
	local self = setmetatable({}, command)
	self.id = id
	self.level = 0
	self.match = "default"
	self.system = system
	self.aliases = {}
	self.context = "server"
	self.arguments = {}

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
	self.level = level
	return self
end

function command:setAlias(primary: string, secondary: string?)
	self.aliases = {primary, secondary :: string}
	if self.chatCommand then
		self.chatCommand.PrimaryAlias = "/"..primary
		self.chatCommand.SecondaryAlias = secondary and "/"..secondary or ""
	end
	return self
end

function command:setContext(context: types.commandContext)
	self.context = context
	return self
end

function command:isInContext(): boolean
	local context = self.context
	if context == "both" or (isServer and context == "server") or (isClient and context == "client") then
		return true
	end

	return false
end

function command:addArgument(id: string, type: types.commandArgumentType, match: types.commandArgumentMatch?)
	table.insert(self.arguments, {
		id = id,
		type = type,
		match = match or "default"
	})
	return self
end

function command:onCallback(callback)
	table.insert(self.callbacks, callback)
	return self
end

function command:hasPermission(player: Player)
	return self.system.flake.permissions:getPlayerLevel(player) >= self.level
end

return command