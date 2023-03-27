--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")

local libraries = script:WaitForChild("libraries")

local util = require(script:WaitForChild("util"))
local types = require(script:WaitForChild("types"))
local cloud = require(script:WaitForChild("cloud"))
local llama = require(libraries:WaitForChild("llama"))
local addons = require(script:WaitForChild("addons"))
local Fusion = require(libraries:WaitForChild("Fusion"))
local actions = require(script:WaitForChild("networking"):WaitForChild("data")).actions
local commands = require(script:WaitForChild("commands"))
local networking = require(script:WaitForChild("networking"))
local permissions = require(script:WaitForChild("permissions"))
local defaultConfig = script:WaitForChild("defaultConfig")
local userInterface = require(script:WaitForChild("userInterface"))

local Value = Fusion.Value
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()

local flake: types.flake = {} :: any
flake.__index = flake

flake.emoji = "🍫"
flake.version = "0.0.1-alpha.1"

function flake.startFlake()
	local self: types.flake = setmetatable({}, flake) :: any
	self:log(`starting flake v{self.version}`)
	if isClient then
		self:log("flake is an open-source, modern & experimental Roblox Admin System created by Voxelified 😊")
	end
	
	if isServer then
		-- see the networking system
		self.connection = Instance.new("RemoteEvent")
		self.connection.Name = "connection"
		self.connection.Parent = script
	else
		self.connection = script:WaitForChild("connection")
		self.flakeFolder = ReplicatedStorage:WaitForChild("flake")
	end
	
	self.player = Players.LocalPlayer
	self.networking = networking.new(self)
	
	self.auditLogs = Value({})
	
	self.addons = addons.new(self)
	self.commands = commands.new(self)
	self.permissions = permissions.new(self)
	
	if isClient then
		self.userInterface = userInterface.new(self)
	end
	self:initialise()
end

function flake:initialise()
	if isServer then
		script.Name = "flakeModule"
		script.Parent = ReplicatedStorage

		self.flakeFolder = ReplicatedStorage:FindFirstChild("flake") or Instance.new("Folder")
		self.flakeFolder.Name = "flake"

		local config = self.flakeFolder:FindFirstChild("config") or defaultConfig:Clone()
		config.Name = "config"
		config.Parent = self.flakeFolder
		
		local defaultConfig = require(defaultConfig)
		self.config = llama.Dictionary.join(defaultConfig :: types.flakeConfig,
			require(config) :: any
		) :: types.flakeConfig
		self.config.cloud = llama.Dictionary.join(defaultConfig.cloud, self.config.cloud)

		self.flakeFolder.Parent = ReplicatedStorage
		task.defer(self.addClientLoader, self)
		
		Players.PlayerAdded:Connect(function(player)
			if self.serverClosed then
				return player:Kick("server closed")
			end
		end)
	else
		local config = self.flakeFolder:WaitForChild("config")
		self.config = llama.Dictionary.join(require(defaultConfig) :: types.flakeConfig,
			require(config) :: any
		) :: types.flakeConfig
	end
	
	-- initialisation order is important!
	self.networking:initialise()
	self.permissions:initialise()
	self.commands:initialise()
	self.addons:initialise()
	
	local cloudConfig = self.config.cloud
	if cloudConfig.enabled then
		local cloud = cloud.new(self)
		self.cloud = cloud
		
		task.defer(cloud.initialise, cloud)
	else
		self:log("cloud system is disabled")
	end
	
	if isClient then
		self.userInterface:initialise()
	end
	self:log(`flake v{self.version} is ready for use!`)
end

function flake:addClientLoader()
	local actor = script.clientActor
	actor:Clone().Parent = StarterPlayerScripts

	local gui = Instance.new("ScreenGui")
	gui.Name = "flakeLoader"
	gui.ResetOnSpawn = false
	actor:Clone().Parent = gui

	for _,player in Players:GetPlayers() do
		task.defer(function()
			gui:Clone().Parent = player.PlayerGui
		end)
	end
end

function flake:addAuditLog(target: string, player: Player?, action: types.auditLogAction)
	local log: types.auditLog = {
		time = os.time(),
		target = target,
		player = player,
		actionType = action
	}
	local list = self.auditLogs
	list:set(util.concat(list:get(false), {log}))
	
	for _,player in Players:GetPlayers() do
		if self.permissions:getPlayerLevel(player) > 0 then
			self:sendPlayerAction(player, actions.ADD_AUDIT_LOG, {log})
		end
	end
end

function flake:kickPlayer(target: Player, reason: string?, executor: Player?)
	target:Kick(reason)
	self:addAuditLog(`@{target.Name}`, executor, "kick-player")
end

function flake:closeServer()
	-- will improve this later
	self.serverClosed = true
	for _,player in Players:GetPlayers() do
		self:kickPlayer(player, "server closed")
	end
end

function flake:notifyPlayer(player: Player, title: string?, body: string, icon: string | types.notificationIcon | nil)
	return self:sendPlayerAction(player, actions.NOTIFY, {title, body, icon})
end

function flake:sendAction(action: number, args: types.connectionArgs)
	return self.networking:sendAction(action, args)
end

function flake:sendPlayerAction(player: Player, action: number, args: types.connectionArgs)
	return self.networking:sendPlayerAction(player, action, args)
end

function flake:log(...)
	warn(self.emoji, "[flake:main]:", ...)
end

return flake