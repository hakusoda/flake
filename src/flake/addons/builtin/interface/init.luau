--!strict
local RunService = game:GetService("RunService")

local flake = script.Parent.Parent.Parent
local classes = flake.classes
local libraries = flake.libraries
local components = script.components

local types = require(script.types)
local llama = require(libraries.llama)
local Addon = require(components.Addon)
local Fusion = require(libraries.Fusion)
local baseAddon = require(classes.baseAddon)
local FlakeInfo = require(components.FlakeInfo)
local flakeTypes = require(flake.types)
local CommandList = require(components.CommandList)

local isClient = RunService:IsClient()

local Value, Computed = Fusion.Value, Fusion.Computed
local interfaceAddon: types.interfaceAddon = setmetatable({}, baseAddon) :: any
interfaceAddon.__index = interfaceAddon :: any
interfaceAddon.id = "builtin-interface"
interfaceAddon.name = "User Interface"
interfaceAddon.icon = {
	main = "rbxassetid://12782343310",
	list = "rbxassetid://12782630681"
}
interfaceAddon.authors = {{
	name = "Voxelified",
	icon = "rbxassetid://12730560612"
}, "Blookerss"}
interfaceAddon.description = "Provides additional interfaces"
interfaceAddon.version = "1.0.0"

function interfaceAddon.new(system: flakeTypes.addons)
	local self: types.interfaceAddon = setmetatable(baseAddon.new(system), interfaceAddon :: any) :: any
	self.viewAddon = Value(nil)
	self.flakeInfoVisible = Value(false)
	self.commandListVisible = Value(false)
	
	return self
end

function interfaceAddon:initialize()
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
		userInterface:addTouchMenuItem({
			icon = "rbxassetid://11568098452",
			onClick = function()
				self.flakeInfoVisible:set(true)
			end
		})
	end
end

function interfaceAddon:createCommand(id: string): flakeTypes.command
	return self.flake.commands:create(id)
end

return interfaceAddon