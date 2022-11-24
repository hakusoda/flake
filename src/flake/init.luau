--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")

local libraries = script:WaitForChild("libraries")

local Cryo = require(libraries:WaitForChild("llama"))
local types = require(script:WaitForChild("types"))
local actions = require(script:WaitForChild("connectionHandler"):WaitForChild("data")).actions
local addonSystem = require(script:WaitForChild("addonSystem"))
local levelSystem = require(script:WaitForChild("levelSystem"))
local defaultConfig = script:WaitForChild("defaultConfig")
local commandSystem = require(script:WaitForChild("commandSystem"))
local userInterface = require(script:WaitForChild("userInterface"))
local connectionHandler = require(script:WaitForChild("connectionHandler"))

local isServer = RunService:IsServer()
local isClient = RunService:IsClient()

local flake: types.flake = {} :: any
flake.__index = flake
flake.version = "1.0.0"

flake.libraries = libraries

function flake.new()
	local self: any = setmetatable({}, flake) :: any
	self.emoji = "🍫"
	self.player = Players.LocalPlayer
	self.addonSystem = addonSystem.new(self)
	self.levelSystem = levelSystem.new(self)
	self.commandSystem = commandSystem.new(self)
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

		self.config = Cryo.Dictionary.join(require(defaultConfig) :: types.flakeConfig,
			require(config) :: any
		) :: types.flakeConfig

		self.flakeFolder.Parent = ReplicatedStorage
		self:addClientActor()
	else
		self.connection = script:WaitForChild("connection")

		self.flakeFolder = ReplicatedStorage:WaitForChild("flake")

		local config = self.flakeFolder:WaitForChild("config")
		self.config = Cryo.Dictionary.join(require(defaultConfig) :: types.flakeConfig,
			require(config) :: any
		) :: types.flakeConfig
	end

	self.connectionHandler = connectionHandler.new(self) :: any

	self.levelSystem:initialize()
	self.connectionHandler:initialize()
	if self.userInterface then
		self.userInterface:initialize()
	end
	self.commandSystem:initialize()
	self.addonSystem:initialize()
	self:log("flake", self.version, "is ready for use!")
end

function flake:addClientActor()
	local actor = script.clientActor
	actor:Clone().Parent = StarterPlayerScripts

	local gui = Instance.new("ScreenGui")
	gui.Name = "flakeLoader"
	gui.ResetOnSpawn = false
	actor:Clone().Parent = gui

	for _,i in pairs(Players:GetPlayers()) do
		gui:Clone().Parent = i.PlayerGui
	end
end

function flake:notifyPlayer(player: Player, title: string?, body: string)
	return self:sendPlayerAction(player, actions.NOTIFY, {title, body})
end

function flake:sendAction(action: number, args: types.connectionArgs)
	return self.connectionHandler:sendAction(action, args)
end

function flake:sendPlayerAction(player: Player, action: number, args: types.connectionArgs)
	return self.connectionHandler:sendPlayerAction(player, action, args)
end

function flake:log(...)
	warn(self.emoji, "[flake:main]:", ...)
end

return flake