--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")

local root = script.Parent.Parent
local libraries = root.libraries

local t = require(root.localisation)()
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
	self.shouldLog = Value(true)

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

function command:setSource(source: types.baseAddon)
	self.source = source
	return self
end

function command:setContext(context: types.commandContext)
	self.context:set(context)
	return self
end

function command:setShouldLog(value: boolean)
	self.shouldLog:set(value)
	return self
end

function command:getSource()
	return self.source
end

function command:getSuggestions(input: string, cursor: number)
	local truncated = string.sub(input, 1, cursor - 1)
	
	local split = string.split(truncated, " ")
	local invalid = {}
	local suggestions: {types.commandArgumentSuggestion} = {}
	
	local length = 0
	for key, argument in self.arguments:get(false) do
		local text = split[key]
		if text then
			length += #text + 1
			if length < cursor then
				continue
			end
			
			local suggestor = argument.suggestor
			local invalidReason = t("argument-error.type-mismatch", {argument})
			if suggestor then
				local index = 0
				suggestor(text, function(text)
					index += 1
					table.insert(suggestions, {
						text = text,
						index = index,
						argument = argument,
						argumentIndex = key
					})
				end, function(reason)
					invalid[argument.id] = reason or invalidReason
				end)
			else
				local type: types.commandArgumentType = argument.type
				if type == "players" then
					text = string.lower(text)
					
					local valid = false
					local selectors: {string} = {"all", "others", "random"}
					for key2, selector in selectors do
						local full = "@"..selector
						if string.find(full, text) == 1 then
							valid = true
							table.insert(suggestions, {
								text = "@"..selector,
								index = key2,
								argument = argument,
								argumentIndex = key
							})
						end
					end
					for key2, player in Players:GetPlayers() do
						local playerName = player.Name
						local displayName = player.DisplayName
						local name = if string.find(string.lower(playerName), text) == 1 then playerName elseif string.find(string.lower(displayName), text) == 1 then displayName else nil
						if name and string.lower(name) ~= text then
							valid = true
							table.insert(suggestions, {
								text = name,
								index = #suggestions + key2,
								argument = argument,
								argumentIndex = key
							})
						end
					end
					
					if not valid then
						invalid[argument.id] = t("argument-error.player-name")
					end
				elseif type == "number" then
					if not tonumber(text) then
						invalid[argument.id] = invalidReason
					end
				end
			end
		end
	end
	return suggestions, invalid
end

function command:isInContext(): boolean
	local context = self.context:get(false)
	if context == "both" or (isServer and context == "server") or (isClient and context == "client") then
		return true
	end

	return false
end

function command:addArgument(id: string, type: types.commandArgumentType, match: types.commandArgumentMatch?, suggestor: types.commandArgumentSuggestor?)
	local list = self.arguments
	list:set(llama.List.join(list:get(false), {{
		id = id,
		type = type,
		match = match or "default",
		suggestor = suggestor
	}}))
	
	return self
end

function command:onCallback(callback)
	table.insert(self.callbacks, callback)
	return self
end

function command:hasPermission(player: Player)
	return self.system.flake.permissions:getPlayerLevel(player) >= self.level:get(false)
end

return command