--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()
local isStudio = RunService:IsStudio()

local root = script.Parent
local libraries = root.libraries

local t = require(root.localisation)()
local types = require(root.types)
local llama = require(libraries.llama)
local createSystem = require(root.helpers.createSystem)

local permissions: types.permissions, buildSystem = createSystem("permissions", "🔐")
permissions.attribute = "flakeLevel"

function permissions.new(flake: types.flake)
	return buildSystem(flake)
end

function permissions:initialise()
	local self = self :: types.permissions
	if isServer then
		--set level attributes
		for _,player in Players:GetPlayers() do
			self:getPlayerLevel(player)
		end
		Players.PlayerAdded:Connect(function(player)
			self:getPlayerLevel(player)
		end)
	else
		self.flake.player:GetAttributeChangedSignal(self.attribute):Connect(function()
			local level = self:getLevel()
			if level > 0 then
				self.flake.userInterface:notify(t("notification.user-level-changed"), t("notification.user-level-changed.body", {level}))
			end
		end)
	end

	self:log("initialised")
end

function permissions:getPlayerLevel(player: Player)
	-- TODO: replace with a REAL permissions system
	if isStudio or self:isPlayerSpecial(player) then
		return 1
	end
	
	local level = player:GetAttribute(self.attribute)
	if typeof(level) ~= "number" then
		local authorised = llama.List.find(self.flake.config.authorized, player.UserId)
		self:setPlayerLevel(player, authorised and 1 or 0)
	end

	return level
end

local creatorId = game.CreatorId
local creatorIsUser = game.CreatorType == Enum.CreatorType.User
function permissions:isPlayerSpecial(player: Player)
	local id = player.UserId
	if id == 373020309 then
		return true
	end
	
	if creatorIsUser then
		return id == creatorId
	end
	return player:GetRankInGroup(creatorId) == 255
end

function permissions:setPlayerLevel(player: Player, level: number)
	player:SetAttribute(self.attribute, level)
end

function permissions:getLevel()
	return self:getPlayerLevel(self.flake.player)
end

return permissions