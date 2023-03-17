--!strict
local RunService = game:GetService("RunService")

local flake = script.Parent.Parent.Parent
local libraries = flake.libraries
local components = script.components

local types = require(script.types)
local llama = require(libraries.llama)
local Addon = require(components.Addon)
local Fusion = require(libraries.Fusion)
local AuditLog = require(components.AuditLog)
local FlakeInfo = require(components.FlakeInfo)
local flakeTypes = require(flake.types)
local CommandList = require(components.CommandList)
local createAddon = require(flake.helpers.createAddon)

local isClient = RunService:IsClient()

local Value, Computed = Fusion.Value, Fusion.Computed
local addon: types.interfaceAddon, buildAddon = createAddon("builtin-interface", "User Interface", "0.0.1-alpha.1")
addon.icon = {
	main = "rbxassetid://12782343310",
	list = "rbxassetid://12782630681"
}
addon.authors = {{
	name = "Voxelified",
	icon = "rbxassetid://12782685021"
}, "Blookerss"}
addon.description = "Provides additional interfaces"

function addon.new(system: flakeTypes.addons)
	local self = buildAddon(system)
	self.viewAddon = Value(nil)
	self.auditLogVisible = Value(false)
	self.flakeInfoVisible = Value(false)
	self.commandListVisible = Value(false)
	
	return self
end

function addon:initialize()
	local self = self :: types.interfaceAddon
	self:createCommand("builtin-info")
	:setAlias("info")
	:setLevel(0)
	:setContext("client")
	:onCallback(function()
		self.flakeInfoVisible:set(true)
	end)

	self:createCommand("builtin-commands")
	:setAlias("commands", "cmds")
	:setLevel(0)
	:setContext("client")
	:onCallback(function()
		self.commandListVisible:set(true)
	end)
	
	self:createCommand("builtin-audit-log")
	:setAlias("auditlog")
	:setLevel(1)
	:setContext("client")
	:onCallback(function()
		self.auditLogVisible:set(true)
	end)
	
	if isClient then
		local userInterface = self.flake.userInterface
		local function addAppComponent(c)
			userInterface:addAppComponent(function(a)
				return c(llama.Dictionary.join(a, { addon = self }))
			end)
		end
		
		addAppComponent(FlakeInfo)
		addAppComponent(CommandList)
		addAppComponent(function()
			return Computed(function()
				local addon = self.viewAddon:get()
				if addon then
					return Addon {
						addon = addon,
						flake = self.flake,
						onClose = function()
							self.viewAddon:set(nil)
						end
					}
				end
				return nil :: any
			end, Fusion.cleanup)
		end)
		addAppComponent(function()
			return AuditLog {
				data = self.flake.auditLogs,
				visible = self.auditLogVisible
			}
		end)
		userInterface:addTouchMenuItem({
			icon = "rbxassetid://11568098452",
			onClick = function()
				self.flakeInfoVisible:set(true)
			end
		})
	end
end

return addon