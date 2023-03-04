--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()
local isClient = RunService:IsClient()

local root = script.Parent
local classes = root.classes
local libraries = root.libraries

local types = require(root.types)
local llama = require(libraries.llama)
local Fusion = require(libraries.Fusion)
local baseSystem = require(classes.baseSystem)

local addons: types.addons = setmetatable({}, baseSystem) :: any
addons.__index = addons :: any
addons.name = "addons"

function addons.new(flake: types.flake)
	local self = setmetatable(baseSystem.new(flake), addons :: any) :: any
	self.emoji = "🧩"
	self.loaded = Fusion.Value({})

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

	self:loadAddon(script.builtin)
	self:loadAddon(self.addonFolder)
	self.addonFolder.ChildAdded:Connect(function(child)
		self:log(`scheduled "{child.Name}" to be loaded`)
		task.delay(5, self.loadAddon, self, child)
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

function addons:getById(id: string)
	for _,addon in self.loaded:get() do
		if addon.id == id then
			return addon :: any
		end
	end
	return nil
end

function addons:loadAddon(module: Instance)
	local context = module:GetAttribute("context")
	if (context == "server" and not isServer) or (context == "client" and not isClient) then
		return
	end
	
	xpcall(function()
		if module:IsA("Folder") then
			for _,i in module:GetChildren() do
				self:loadAddon(i)
			end
		elseif module:IsA("ModuleScript") then
			if module.Name == "MainModule" then
				return self:loadAddon(require(module) :: any)
			end
			local addon: types.baseAddon = require(module).new(self) :: any
			self.loaded:set(llama.List.join(self.loaded:get(), {addon}))
			
			task.defer(addon.initialize, addon)
		end
	end, function(err)
		if isServer then
			for _,player in Players:GetPlayers() do
				if self.flake.permissions:getPlayerLevel(player) > 0 then
					self.flake:notifyPlayer(player, "Addon System Error (Server)", `Failed to import <b>{module.Name}</b>.`)
				end
			end
		else
			self.flake.userInterface:notify("Addon System Error (Client)", `Failed to import <b>{module.Name}</b>.`)
		end
		self:log("import error!", err)
	end)
end

return addons