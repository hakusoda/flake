--!strict
local Players = game:GetService("Players")

local root = script.Parent
local classes = root.classes
local libraries = root.libraries

local types = require(root.types)
local llama = require(libraries.llama)
local Fusion = require(libraries.Fusion)
local command = require(script.command)
local baseSystem = require(classes.baseSystem)

local Value = Fusion.Value
local commands: types.commands = setmetatable({}, baseSystem) :: any
commands.__index = commands :: any
commands.name = "commands"

function commands.new(flake: types.flake)
	local self = setmetatable(baseSystem.new(flake), commands :: any) :: any
	self.emoji = "📂"
	self.commands = Value({})

	return self
end

function commands:initialize()
	self:log("initialized")
end

function commands:getById(id: string)
	local cmds = self.commands:get()
	return cmds[llama.List.findWhere(cmds, function(command)
		return command.id == id
	end)]
end

function commands:getByAlias(alias: string)
	local cmds = self.commands:get()
	return cmds[llama.List.findWhere(cmds, function(command)
		return llama.List.find(command.aliases:get(), alias)
	end)]
end

function commands:create(id: string)
	local command = command.new(id, self)
	local chatCommand = command.chatCommand
	if chatCommand then
		chatCommand.Triggered:Connect(function(source: TextSource, text: string)
			if not command:isInContext() then
				return
			end
			local player: Player = Players:GetPlayerByUserId(source.UserId)
			if not command:hasPermission(player) then
				local level = self.flake.permissions:getPlayerLevel(player)
				self.flake:notifyPlayer(player, "Command error", "You do not have permission to run <b>"..command.id.."</b>.")
				return self:log(player.Name.."'s level ("..level..") is not high enough to run", command.id, "("..command.level:get()..")")
			end

			local text2 = string.split(text, " ")
			table.remove(text2, 1)

			local arguments = {}
			for key, arg in command.arguments:get() do
				arguments[key] = self:processArgument(player, arg, text2, key)
			end

			self:processCommand(command, player, arguments)
		end)
	end
	self:emitEvent("COMMAND_CREATED")
	
	self.commands:set(llama.List.join(self.commands:get(), {command}))
	return command
end

function commands:processCommand(command: types.command, executor: Player, arguments)
	self:execute(command, executor, arguments)
end

function commands:processCommandString(player: Player, text: string)
	local text2 = string.split(text, " ")
	local command = self:getByAlias(text2[1])
	table.remove(text2, 1)

	assert(command, "Command does not exist.")
	if not command:isInContext() then
		return
	end
	if not command:hasPermission(player) then
		local level = self.flake.permissions:getPlayerLevel(player)
		self.flake:notifyPlayer(player, "Command error", "You do not have permission to run <b>"..command.id.."</b>.")
		return self:log(player.Name.."'s level ("..level..") is not high enough to run", command.id, "("..command.level:get()..")")
	end

	local arguments = {}
	for key, arg in command.arguments:get() do
		arguments[key] = self:processArgument(player, arg, text2, key)
	end

	self:execute(command, player, arguments)
end

function commands:execute(command: types.command, player: Player, args: {any})
	for _,callback in command.callbacks do
		callback(command, player, table.unpack(args))
	end
	self:log("executed command", command.id)
end

function commands:processArgument(player: Player, argument: types.commandArgument, text: {string}, pos: number)
	if argument.type == "players" then
		local players = {}
		for _,part in string.split(text[pos] or "", ",") do
			local lower = string.lower(part or "")
			if #part == 0 or lower == "me" or lower == "@s" then
				table.insert(players, player)
				continue
			end

			local allPlayers = Players:GetPlayers()
			if lower == "all" or lower == "@a" then
				players = llama.List.join(players, allPlayers)
				continue
			end
			if lower == "others" or lower == "@o" then
				players = llama.List.join(players,
					llama.List.filter(allPlayers, function(p)
						return p.UserId ~= player.UserId
					end
				))
				continue
			end
			for _,player2 in allPlayers do
				local lowerName = string.lower(player2.Name)
				if string.find(lowerName, lower) == 1 then
					table.insert(players, player2)
					continue
				end

				local lowerDisplay = string.lower(player2.DisplayName)
				if string.find(lowerDisplay, lower) == 1 then
					table.insert(players, player2)
				end
			end
		end
		return players
	elseif argument.type == "string" then
		if argument.match == "rest" then
			return table.concat(text, " ", pos)
		end
		return text[pos]
	elseif argument.type == "strings" then
		if argument.match == "rest" then
			return string.split(table.concat(text, " ", pos))
		end
		return string.split(text[pos], ",")
	elseif argument.type == "number" then
		return tonumber(text[pos]) or 0
	end
end

return commands