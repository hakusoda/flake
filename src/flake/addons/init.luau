--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()

local root = script.Parent
local classes = root.classes

local types = require(root.types)
local baseSystem = require(classes.baseSystem)

local addons: types.addons = setmetatable({}, baseSystem) :: any
addons.__index = addons :: any
addons.name = "addons"

function addons.new(flake: types.flake)
	local self = setmetatable(baseSystem.new(flake), addons :: any) :: any
	self.emoji = "🧩"
	self.addons = {}

	return self
end

function addons:initialize()
	local self = self :: types.addons
	if isServer then
		local flakeFolder = self.flake.flakeFolder

		self.addonFolder = flakeFolder:FindFirstChild("addons") or Instance.new("Folder") :: any
		self.addonFolder.Name = "addons"
		self.addonFolder.Parent = flakeFolder
	else
		local flakeFolder = self.flake.flakeFolder
		self.addonFolder = flakeFolder:WaitForChild("addons") :: Folder
	end

	local builtin = script:WaitForChild("builtin")
	for _,child in builtin:GetChildren() do
		self:loadAddon(child)
	end
	builtin.ChildAdded:Connect(function(child)
		self:loadAddon(child)
	end)

	for _,child in self.addonFolder:GetChildren() do
		self:loadAddon(child)
	end
	self.addonFolder.ChildAdded:Connect(function(child)
		self:loadAddon(child)
	end)

	if isServer then
		local toImport = self.flake.config.importAddons
		if typeof(toImport) == "table" then
			for _,i in toImport do
				if typeof(i) == "number" then
					xpcall(function()
						(require(i) :: any).Parent = self.addonFolder
					end, warn)
				end
			end
		end
	end

	self:log("initialized")
end

function addons:loadAddon(module: Instance)
	xpcall(function()
		if module:IsA("Folder") then
			for _,i in module:GetChildren() do
				self:loadAddon(i)
			end
			return
		elseif module:IsA("ModuleScript") then
			if module.Name == "MainModule" then
				module = require(module) :: any
			end
			local addon: types.baseAddon = require(module).new(self) :: any
			task.defer(addon.initialize, addon)

			self.addons[addon.id] = addon

			if isServer then
				for _,player in Players:GetPlayers() do
					if self.flake.permissions:getPlayerLevel(player) >= 1 then
						self.flake:notifyPlayer(player, "Addon Imported", addon.name.." v"..addon.version.." has been automatically loaded.")
					end
				end
			end
		end
	end, function(err)
		if isServer then
			for _,player in Players:GetPlayers() do
				if self.flake.permissions:getPlayerLevel(player) >= 1 then
					self.flake:notifyPlayer(player, "Addon System Error (Server)", "Failed to import <b>"..module.Name.."</b>.")
				end
			end
		else
			self.flake.userInterface:notify("Addon System Error (Client)", "Failed to import <b>"..module.Name.."</b>.")
		end
		self:log("import error!", err)
	end)
end

return addons