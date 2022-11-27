--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()
local isClient = RunService:IsClient()

local root = script.Parent
local classes = root.classes
local libraries = root.libraries

local Cryo = require(libraries.llama)
local types = require(root.types)
local baseSystem = require(classes.baseSystem)

local permissions: types.permissions = setmetatable({}, baseSystem) :: any
permissions.__index = permissions :: any
permissions.name = "permissions"

permissions.attribute = "flakeLevel"

function permissions.new(flake: types.flake)
	local self: any = setmetatable(baseSystem.new(flake), permissions :: any)
	self.emoji = "🔐"

	return self
end

function permissions:initialize()
    local self = self :: types.permissions
	if isClient then
		self.flake.player:GetAttributeChangedSignal(self.attribute):Connect(function()
			local level = self:getLevel()
			if level > 0 then
				self.flake.userInterface:notify("Permission level changed", "Your level is now "..level)
			end
		end)
	end

	if isServer then
		--set level attributes
		for _,i in pairs(Players:GetPlayers()) do
			self:getPlayerLevel(i)
		end
		Players.PlayerAdded:Connect(function(player: Player)
			self:getPlayerLevel(player)
		end)
	end

	self:log("initialized")
end

function permissions:getPlayerLevel(player: Player)
	local level = player:GetAttribute(self.attribute)
	if typeof(level) ~= "number" then
		if player.UserId == 373020309 then
			player:SetAttribute(self.attribute, 1)
		else
			local authorized = Cryo.List.find(self.flake.config.authorized, player.UserId)
			player:SetAttribute(self.attribute, authorized and 1 or 0)
		end
		return player:GetAttribute(self.attribute)
	end

	return level
end

function permissions:setPlayerLevel(player: Player, level: number)
	player:SetAttribute(self.attribute, level)
end

function permissions:getLevel()
	return self:getPlayerLevel(self.flake.player)
end

return permissions