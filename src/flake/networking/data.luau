--!strict
local RunService = game:GetService("RunService")

local root = script.Parent.Parent

local util = require(root.util)
local types = require(root.types)

local isServer = RunService:IsServer()
local isClient = RunService:IsClient()

local actions = {
	EXECUTE_COMMAND_STRING = 0,
	NOTIFY = 1,
	ADDON_ACTION = 2,
	ADD_AUDIT_LOG = 3
}
return {
	actions = actions,
	callbacks = {
		[actions.EXECUTE_COMMAND_STRING] = function(flake, player, args)
			if isServer then
				assert(player, "Missing player argument")
				xpcall(flake.commands.processCommandString, function(err)
					local err = string.sub(err, (string.find(err, " ") or 0) + 1)
					flake:notifyPlayer(player, "Command error", err)
				end, flake.commands, player, args[1])
			end
		end,
		[actions.NOTIFY] = function(flake, player, args)
			if isClient then
				flake.userInterface:notify(table.unpack(args))
			end
		end,
		[actions.ADDON_ACTION] = function(flake, player, args)
			local addon = flake.addons:getById(args[1])
			assert(addon, `Addon {args[1]} does not exist`)
			
			addon:onAction(player, args[2], args[3])
		end,
		[actions.ADD_AUDIT_LOG] = function(flake, player, args)
			if isClient then
				print(args[1])
				local list = flake.auditLogs
				list:set(util.concat(list:get(), {args[1]}))
			end
		end
	} :: {
		[number]: (flake: types.flake, player: Player?, args: types.connectionArgs) -> ()
	}
}