--!strict
local Players = game:GetService("Players")

local root = script.Parent
local classes = root.classes
local libraries = root.libraries

local Cryo = require(libraries.llama)
local types = require(root.types)
local command = require(script.command)
local baseSystem = require(classes.baseSystem)

local commandSystem: types.commandSystem = setmetatable({}, baseSystem) :: any
commandSystem.__index = commandSystem :: any
commandSystem.name = "commandSystem"

function commandSystem.new(flake: types.flake)
	local self = setmetatable(baseSystem.new(flake), commandSystem :: any) :: any
	self.emoji = "📂"
	self.commands = {}

	return self
end

function commandSystem:initialize()
	self:log("initialized")
end

function commandSystem:getById(id: string)
	return self.commands[Cryo.List.findWhere(self.commands, function(command)
		return command.id == id
	end)]
end

function commandSystem:getByAlias(alias: string)
	return self.commands[Cryo.List.findWhere(self.commands, function(command)
		return Cryo.List.find(command.aliases, alias)
	end)]
end

function commandSystem:create(id: string)
	local command = command.new(id, self)
	local chatCommand = command.chatCommand
	if chatCommand then
		chatCommand.Triggered:Connect(function(source: TextSource, text: string)
			if not command:isInContext() then
				return
			end
			local player: Player = Players:GetPlayerByUserId(source.UserId)
			if not command:hasPermission(player) then
				local level = self.flake.levelSystem:getPlayerLevel(player)
				self.flake:notifyPlayer(player, "Command error", "You do not have permission to run <b>"..command.id.."</b>.")
				return self:log(player.Name.."'s level ("..level..") is not high enough to run", command.id, "("..command.level..")")
			end

			local text2 = string.split(text, " ")
			table.remove(text2, 1)

			local arguments = {}
			for key, arg in pairs(command.arguments) do
				arguments[key] = self:processArgument(player, arg, text2, key)
			end

			self:processCommand(command, player, arguments)
		end)
	end
	self:emitEvent("COMMAND_CREATED")

	table.insert(self.commands, command)
	return command
end

function commandSystem:processCommand(command: types.command, executor: Player, arguments)
	self:execute(command, executor, arguments)
end

function commandSystem:processCommandString(player: Player, text: string)
	local text2 = string.split(text, " ")
	local command = self:getByAlias(text2[1])
	table.remove(text2, 1)

	assert(command, "Command does not exist.")
	if not command:isInContext() then
		return
	end
	if not command:hasPermission(player) then
		local level = self.flake.levelSystem:getPlayerLevel(player)
		self.flake:notifyPlayer(player, "Command error", "You do not have permission to run <b>"..command.id.."</b>.")
		return self:log(player.Name.."'s level ("..level..") is not high enough to run", command.id, "("..command.level..")")
	end

	local arguments = {}
	for key, arg in pairs(command.arguments) do
		arguments[key] = self:processArgument(player, arg, text2, key)
	end

	self:execute(command, player, arguments)
end

function commandSystem:execute(command: types.command, player: Player, args: {any})
	for _,callback in pairs(command.callbacks) do
		callback(command, player, table.unpack(args))
	end
	self:log("executed command", command.id)
end

function commandSystem:processArgument(player: Player, argument: types.commandArgument, text: {string}, pos: number)
	if argument.type == "players" then
		local players = {}
		for _,part in pairs(string.split(text[pos] or "", ",")) do
			local lower = string.lower(part or "")
			if #part == 0 or lower == "me" or lower == "@s" then
				table.insert(players, player)
				continue
			end

			local allPlayers = Players:GetPlayers()
			if lower == "all" or lower == "@a" then
				players = Cryo.List.join(players, allPlayers)
				continue
			end
			if lower == "others" or lower == "@o" then
				players = Cryo.List.join(players,
					Cryo.List.filter(allPlayers, function(p)
						return p.UserId ~= player.UserId
					end
				))
				continue
			end
			for _,player2 in pairs(allPlayers) do
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

return commandSystem