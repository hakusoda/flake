--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local root = script.Parent
local libraries = root.libraries

local util = require(root.util)
local types = require(root.types)
local llama = require(libraries.llama)
local Fusion = require(libraries.Fusion)
local command = require(script.command)
local createSystem = require(root.helpers.createSystem)

local Value = Fusion.Value
local isServer = RunService:IsServer()

local commands: types.commands, buildSystem = createSystem("commands", "📒")
function commands.new(flake: types.flake)
	local self = buildSystem(flake)
	self.commands = Value({})

	return self
end

function commands:initialise()
	self:log("initialised")
end

function commands:getAll()
	return self.commands:get(false)
end

function commands:getById(id: string)
	local cmds = self.commands:get(false)
	return cmds[llama.List.findWhere(cmds, function(command)
		return command.id == id
	end)]
end

function commands:getByAlias(alias: string)
	local cmds = self.commands:get(false)
	return cmds[llama.List.findWhere(cmds, function(command)
		return llama.List.find(command.aliases:get(false), alias)
	end)]
end

function commands:create(id: string)
	if table.find(self.flake.config.disableCommands, id) then
		return command.new(id, self)
	end
	
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
				return self:log(player.Name.."'s level ("..level..") is not high enough to run", command.id, "("..command.level:get(false)..")")
			end

			local text2 = string.split(text, " ")
			table.remove(text2, 1)

			local arguments = {}
			for key, arg in command.arguments:get(false) do
				arguments[key] = self:processArgument(player, arg, text2, key)
			end

			self:execute(command, player, arguments, string.sub(text, 2))
		end)
	end
	self:emitEvent("COMMAND_CREATED")
	
	self.commands:set(util.concat(self.commands:get(false), {command}))
	return command
end

function commands:getCommand(input: string)
	local text = string.split(input, " ")[1]
	local matches: {types.commandSuggestion} = {}
	
	local index = 0
	for _,command: types.command in self.commands:get(false) :: {any} do
		for _,alias in command.aliases:get(false) do
			if text == alias then
				return command, {}
			elseif string.find(alias, text) == 1 then
				index += 1
				table.insert(matches, {
					text = alias,
					index = index,
					command = command
				})
			end
		end
	end

	return nil, matches
end

function commands:processCommandString(player: Player, text: string, ignoreLevel: boolean?)
	local text2 = string.split(text, " ")
	local command = self:getByAlias(text2[1])
	table.remove(text2, 1)

	assert(command, "Command does not exist.")
	if not command:isInContext() then
		return
	end
	if not command:hasPermission(player) and not ignoreLevel then
		local level = self.flake.permissions:getPlayerLevel(player)
		self.flake:notifyPlayer(player, "Command error", "You do not have permission to run <b>"..command.id.."</b>.")
		return self:log(player.Name.."'s level ("..level..") is not high enough to run", command.id, "("..command.level:get(false)..")")
	end

	local arguments = {}
	for key, arg in command.arguments:get(false) do
		arguments[key] = self:processArgument(player, arg, text2, key)
	end

	self:execute(command, player, arguments, text)
end

function commands:execute(command: types.command, player: Player, args: {any}, sourceString: string?)
	for _,callback in command.callbacks do
		task.spawn(callback, command, player, table.unpack(args))
	end
	if isServer and command.shouldLog:get(false) then
		self.flake:addAuditLog(`/{sourceString or command.aliases:get(false)[1]}`, player, "execute-command")
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
			if lower == "@all" then
				players = util.concat(players, allPlayers)
				continue
			end
			if lower == "@others" then
				players = util.concat(players,
					llama.List.filter(allPlayers, function(p)
						return p.UserId ~= player.UserId
					end
				))
				continue
			end
			if lower == "@random" then
				players = {players[math.random(#players)]}
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