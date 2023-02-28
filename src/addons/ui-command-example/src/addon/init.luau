--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local isClient = RunService:IsClient()
local localPlayer = Players.LocalPlayer

local flake = ReplicatedStorage.flake
local store = script:WaitForChild("store")
local actions = store:WaitForChild("actions")
local components = script:WaitForChild("components")

local types = require(script:WaitForChild("types"))
local Example = require(components:WaitForChild("Example")) -- this is our ui component!
local baseAddon: types.baseAddon = require(flake:WaitForChild("baseAddon"))
local roduxStore = require(store) -- we need this to be able to show our ui!
local SetExampleVisible = require(actions:WaitForChild("SetExampleVisible")) -- we need this to change the ui visibility!

type exampleAddon = types.baseAddon & {
    store: any,

	createCommand: (self: exampleAddon, id: string) -> types.command
}

local exampleAddon: exampleAddon = setmetatable({}, baseAddon) :: any
exampleAddon.__index = exampleAddon :: any
exampleAddon.id = "ui-command-example"
exampleAddon.name = "UI Command Example"
exampleAddon.authors = {"Voxelified"}
exampleAddon.description = "Example for a custom user interface"
exampleAddon.version = "1.0.0"

function exampleAddon.new(system)
	local self: any = setmetatable(baseAddon.new(system), exampleAddon :: any)
    self.store = roduxStore

	return self
end

function exampleAddon:initialize()
	local self = self :: exampleAddon

	self:createCommand("example-ui")
    :setAlias("exampleui")
    :setLevel(0)
    :setContext("client") -- this MUST be set to the Client Context!
    :onCallback(function()
		-- this makes our ui appear, yippee!
		-- this isn't restricted to just commands, you can put this anywhere!
        self.store:dispatch(SetExampleVisible(true))
    end)

	-- make sure to check if the userInterface exists first, otherwise this would error on the server!
    if self.flake.userInterface then
        self.flake.userInterface:addAppComponent(Example)
    end
end

function exampleAddon:createCommand(id: string): types.command
	return self.flake.commands:create(id)
end

return exampleAddon