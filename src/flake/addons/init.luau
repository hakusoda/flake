--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()
local isClient = RunService:IsClient()

local root = script.Parent
local libraries = root.libraries

local t = require(root.localisation)()
local util = require(root.util)
local types = require(root.types)
local llama = require(libraries.llama)
local Fusion = require(libraries.Fusion)
local createSystem = require(root.helpers.createSystem)

local addons: types.addons, buildSystem = createSystem("addons", "🧩")
function addons.new(flake: types.flake)
	local self = buildSystem(flake)
	self.loaded = Fusion.Value({})

	return self
end

function addons:initialise()
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

	self:log("initialised")
	task.defer(self.loadAddons, self)
end

function addons:loadAddons()
	local folder = self.addonFolder
	local builtin = script.builtin
	self:log(`importing {#folder:GetChildren()} community addon(s) & {#builtin:GetChildren()} built-in addon(s)`)
	
	self:loadAddon(builtin)
	self:loadAddon(folder)
	self.addonFolder.ChildAdded:Connect(function(child)
		self:log(`scheduled "{child.Name}" to be loaded`)
		task.delay(5, self.loadAddon, self, child)
	end)

	if isServer then
		local toImport = self.flake.config.importAddons
		if typeof(toImport) == "table" then
			for _,module in toImport do
				task.defer(function()
					if typeof(module) == "number" then
						xpcall(function()
							(require(module) :: any).Parent = self.addonFolder
						end, warn)
					end
				end)
			end
		end
	end
end

function addons:getById(id: string)
	for _,addon in self.loaded:get(false) do
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
			for _,child in module:GetChildren() do
				self:loadAddon(child)
			end
		elseif module:IsA("ModuleScript") then
			if module.Name == "MainModule" then
				return self:loadAddon(require(module) :: any)
			end
			local class: types.baseAddon = require(module) :: any
			if not table.find(self.flake.config.disableAddons, class.id) then
				local addon = class.new(self)
				self.loaded:set(llama.List.join(self.loaded:get(false), {addon}))
				
				self:log(`imported addon: {addon.id} v{addon.version} by {util.authorsToString(addon.authors)}`)
				task.defer(addon.initialize, addon)
			end
		end
	end, function(err)
		if isServer then
			for _,player in Players:GetPlayers() do
				if self.flake.permissions:getPlayerLevel(player) > 0 then
					self.flake:notifyPlayer(player, "Addon System Error (Server)", `Failed to import <b>{module.Name}</b>.`)
				end
			end
		else
			self.flake.userInterface:notify(t("error.addon-error"), t("error.addon-import-fail", {module.Name}))
		end
		self:log("import error!", err)
	end)
end

return addons