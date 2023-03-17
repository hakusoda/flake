--!strict
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()

local flake = script.Parent.Parent.Parent
local helpers = flake.helpers

local t = require(flake.localisation)()
local types = require(flake.types)
local createAddon = require(helpers.createAddon)

export type commandsAddon = types.baseAddon & {
	loadAddonCommand: types.command
}
local addonActions = {
	LOAD_ADDON = 0,
	SUDO = 1
}

local addon: commandsAddon, buildAddon = createAddon("builtin-commands", "Commands", "0.0.1-alpha.1")
addon.icon = {
	main = "rbxassetid://12782343310",
	list = "rbxassetid://12782630681"
}
addon.authors = {{
	name = "Voxelified",
	icon = "rbxassetid://12782685021"
}, "Blookerss"}
addon.description = "Provides advanced commands"

function addon.new(system: types.addons)
	local self = buildAddon(system)
	self.actions = addonActions

	return self
end

function addon:initialize()
	local self = self :: commandsAddon
	self.loadAddonCommand = self:createCommand("builtin-import-addon")
	:setAlias("importaddon", "loadaddon")
	:setLevel(1)
	:setContext("client")
	:addArgument("id", "number")
	:onCallback(function(cmd, executor: Player, id: number)
		self.flake.userInterface:createPrompt({
			title = t("addon-import"),
			body = t("addon-import.body", {id}),

			confirmButton = function()
				self:sendAction(addonActions.LOAD_ADDON, {id})
			end,
			cancelButton = function()

			end
		})
	end)
	
	local function sudo(safe: boolean, targets: {Player}, input: string)
		local cmds = self.flake.commands
		local command = cmds:getByAlias(string.split(input, " ")[1])
		if command then
			local context = command.context:get()
			for _,i in targets do
				if context == "server" then
					cmds:processCommandString(i, input, not safe)
				elseif context == "client" then
					self:sendAction(addonActions.SUDO, {input})
				end
			end
		end
	end
	
	self:createCommand("builtin-sudo-safe")
	:setAlias("sudo")
	:setLevel(1)
	:setContext("server")
	:addArgument("targets", "players")
	:addArgument("input", "string", "rest")
	:onCallback(function(cmd, executor: Player, targets: {Player}, input: string)
		sudo(true, targets, input)
	end)
	
	self:createCommand("builtin-sudo-unsafe")
	:setAlias("sudounsafe")
	:setLevel(1)
	:setContext("server")
	:addArgument("targets", "players")
	:addArgument("input", "string", "rest")
	:onCallback(function(cmd, executor: Player, targets: {Player}, input: string)
		sudo(false, targets, input)
	end)
end

function addon:onAction(player: Player?, action: number, args: types.connectionArgs)
	local self = self :: commandsAddon
	self.base.onAction(self, player, action, args)

	if action == addonActions.LOAD_ADDON then
		if isServer then
			assert(player, "Missing player argument")
			if self.loadAddonCommand:hasPermission(player) then
				self.flake:notifyPlayer(player, "Importing Addon", "Attempting to require <b>"..args[1].."</b>...")

				xpcall(function()
					local value = require(args[1]) :: any
					if typeof(value) == "Instance" and value:IsA("ModuleScript") then
						value.Parent = self.flake.addons.addonFolder
						self.flake:addAuditLog(value.Name, player, "import-addon")
					else
						self.flake:notifyPlayer(player, "Addon Import Failed", "A ModuleScript was not returned.")
					end
				end, function(err)
					self.flake:notifyPlayer(player, "Addon Import Failed", "An unknown error occurred.")
					warn(err)
				end)
			end
		end
	elseif action == addonActions.SUDO then
		self.flake.commands:processCommandString(self.flake.player, args[1], true)
	end
end

return addon