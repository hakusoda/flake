--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")

local libraries = script:WaitForChild("libraries")

local types = require(script:WaitForChild("types"))
local llama = require(libraries:WaitForChild("llama"))
local addons = require(script:WaitForChild("addons"))
local actions = require(script:WaitForChild("networking"):WaitForChild("data")).actions
local commands = require(script:WaitForChild("commands"))
local networking = require(script:WaitForChild("networking"))
local permissions = require(script:WaitForChild("permissions"))
local defaultConfig = script:WaitForChild("defaultConfig")
local userInterface = require(script:WaitForChild("userInterface"))

local isServer = RunService:IsServer()
local isClient = RunService:IsClient()

local flake: types.flake = {} :: any
flake.__index = flake
flake.version = "0.0.1-alpha.1"

flake.libraries = libraries

function flake.new()
	local self: any = setmetatable({}, flake) :: any
	self.emoji = "🍫"
	self.player = Players.LocalPlayer
	self.addons = addons.new(self)
    self.commands = commands.new(self)
	self.permissions = permissions.new(self)
	if isClient then
		self.userInterface = userInterface.new(self)
	end

	self:initialize()
	return self
end

function flake:initialize()
	if isServer then
		self.connection = Instance.new("RemoteEvent")
		self.connection.Name = "connection"
		self.connection.Parent = script

		script.Name = "flakeModule"
		script.Parent = ReplicatedStorage

		self.flakeFolder = ReplicatedStorage:FindFirstChild("flake") or Instance.new("Folder")
		self.flakeFolder.Name = "flake"

		local config = self.flakeFolder:FindFirstChild("config") or defaultConfig:Clone()
		config.Name = "config"
		config.Parent = self.flakeFolder

		local baseAddon = script.classes.baseAddon:Clone()
		baseAddon.Parent = self.flakeFolder

		self.config = llama.Dictionary.join(require(defaultConfig) :: types.flakeConfig,
			require(config) :: any
		) :: types.flakeConfig

		self.flakeFolder.Parent = ReplicatedStorage
		self:addClientActor()
	else
		self.connection = script:WaitForChild("connection")

		self.flakeFolder = ReplicatedStorage:WaitForChild("flake")

		local config = self.flakeFolder:WaitForChild("config")
		self.config = llama.Dictionary.join(require(defaultConfig) :: types.flakeConfig,
			require(config) :: any
		) :: types.flakeConfig
	end

	self.networking = networking.new(self) :: any

    self.networking:initialize()
	self.permissions:initialize()
	self.commands:initialize()
	self.addons:initialize()

    if self.userInterface then
		self.userInterface:initialize()
	end
	self:log("flake", self.version, "is ready for use!")
end

function flake:addClientActor()
	local actor = script.clientActor
	actor:Clone().Parent = StarterPlayerScripts

	local gui = Instance.new("ScreenGui")
	gui.Name = "flakeLoader"
	gui.ResetOnSpawn = false
	actor:Clone().Parent = gui

	for _,i in Players:GetPlayers() do
		gui:Clone().Parent = i.PlayerGui
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