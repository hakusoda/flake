--!strict
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()

local flake = script.Parent.Parent.Parent
local classes = flake.classes
local actions = flake.store.actions

local types = require(flake.types)
local baseAddon = require(classes.baseAddon)
local SetFlakeInfoVisible = require(actions.SetFlakeInfoVisible)
local SetCommandListVisible = require(actions.SetCommandListVisible)

type commandsAddon = types.baseAddon & {
	loadAddonCommand: types.command,

	createCommand: (self: commandsAddon, id: string) -> types.command
}
local addonActions = {
	LOAD_ADDON = 0
}

local commandsAddon: commandsAddon = setmetatable({}, baseAddon) :: any
commandsAddon.__index = commandsAddon :: any
commandsAddon.id = "builtin-commands"
commandsAddon.name = "flake - Commands"
commandsAddon.icon = "rbxassetid://11259281331"
commandsAddon.authors = {"Voxelified"}
commandsAddon.description = "Provides built-in commands"
commandsAddon.version = "1.0.0"

function commandsAddon.new(system: types.addons)
	local self = setmetatable(baseAddon.new(system), commandsAddon :: any) :: any
	self.actions = addonActions

	return self
end

function commandsAddon:initialize()
    local self = self :: commandsAddon
	self:createCommand("builtin-info")
	:setAlias("info")
	:setLevel(0)
	:setContext("client")
	:onCallback(function()
		self.flake.store:dispatch(SetFlakeInfoVisible(true))
	end)

	self:createCommand("builtin-commands")
	:setAlias("commands", "cmds")
	:setLevel(0)
	:setContext("client")
	:onCallback(function()
		self.flake.store:dispatch(SetCommandListVisible(true))
	end)

	self.loadAddonCommand = self:createCommand("builtin-load-addon")
	:setAlias("loadaddon")
	:setLevel(1)
	:setContext("client")
	:addArgument("id", "number")
	:onCallback(function(cmd, executor: Player, id: number)
		self.flake.userInterface:createPrompt({
			body = "Are you sure you want to load <b>"..id.."</b>?<br/>The contained model may be dangerous!",
			confirmButton = function()
				self:sendAction(addonActions.LOAD_ADDON, {id})
			end,
			cancelButton = function()

			end
		})
	end)
end

function commandsAddon:onAction(player: Player?, action: number, args: types.connectionArgs)
    local self = self :: commandsAddon
	baseAddon.onAction(self, player, action, args)

	if action == addonActions.LOAD_ADDON then
		if isServer then
			assert(player, "Missing player argument")
			if self.loadAddonCommand:hasPermission(player) then
				self.flake:notifyPlayer(player, "Importing Addon", "Attempting to require <b>"..args[1].."</b>...")

				xpcall(function()
					local value = require(args[1]) :: any
					if typeof(value) == "Instance" and value:IsA("ModuleScript") then
						value.Parent = self.flake.addons.addonFolder
					else
						self.flake:notifyPlayer(player, "Addon Import Failed", "A ModuleScript was not returned.")
					end
				end, function(err)
					self.flake:notifyPlayer(player, "Addon Import Failed", "An unknown error occurred.")
					warn(err)
				end)
			end
		end
	end
end

function commandsAddon:createCommand(id: string): types.command
	return self.flake.commands:create(id)
end

return commandsAddon