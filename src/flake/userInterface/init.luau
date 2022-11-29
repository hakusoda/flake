--!strict
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local root = script.Parent
local sounds = script.sounds
local classes = root.classes
local actions = root.store.actions
local libraries = root.libraries
local components = script.components

local App = require(components.App)
local types = require(root.types)
local Roact = require(libraries["roact-compat"])
local baseSystem = require(classes.baseSystem)
local RoactRodux = require(libraries["roact-rodux"])
local CreatePrompt = require(actions.CreatePrompt)
local flakeContext = require(components.flakeContext)
local AddNotification = require(actions.AddNotification)
local AddAppComponent = require(actions.AddAppComponent)
local AddTouchMenuItem = require(actions.AddTouchMenuItem)
local SetTouchMenuVisible = require(actions.SetTouchMenuVisible)
local SetFlakeInfoVisible = require(actions.SetFlakeInfoVisible)
local SetCommandBarVisible = require(actions.SetCommandBarVisible)
local SetCommandBarCommands = require(actions.SetCommandBarCommands)

local userInterface: types.userInterface = setmetatable({}, baseSystem) :: any
userInterface.__index = userInterface :: any
userInterface.name = "userInterface"

userInterface.components = components

function userInterface.new(flake: types.flake)
	local self: any = setmetatable(baseSystem.new(flake), userInterface :: any)
	self.emoji = "💻"

	return self
end

function userInterface:initialize()
	local self = self :: types.userInterface
	local gui = Instance.new("ScreenGui")
	gui.Name = "flakeInterface"
	gui.DisplayOrder = 2147483647
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = self.flake.player:WaitForChild("PlayerGui")

	self.gui = gui
	gui:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not gui.Enabled then
			gui.Enabled = true
		end
	end)

	UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean)
		if not gameProcessedEvent then
			local keycode = input.KeyCode
			if keycode == Enum.KeyCode.BackSlash and (not self.flake.config.hidden or self.flake.permissions:getLevel() > 0) then
				self.flake.store:dispatch(SetCommandBarVisible(true))
			end
		end
	end)

	self:updateTouchMenu()
	UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(function()
		self:updateTouchMenu()
	end)
	self.flake.player:GetAttributeChangedSignal(self.flake.permissions.attribute):Connect(function()
		self:updateTouchMenu()
	end)

	local commandSystem = self.flake.commands
	self.flake.store:dispatch(SetCommandBarCommands(commandSystem.commands))

	commandSystem:onEvent("COMMAND_CREATED", function()
		self.flake.store:dispatch(SetCommandBarCommands(commandSystem.commands))
	end)

	self:addTouchMenuItem({
		icon = "rbxassetid://11568197675",
		onClick = function()
			self.flake.store:dispatch(SetCommandBarVisible(true))
		end
	})
	self:addTouchMenuItem({
		icon = "rbxassetid://11568098452",
		onClick = function()
			self.flake.store:dispatch(SetFlakeInfoVisible(true))
		end
	})

	local app = Roact.createElement(RoactRodux.StoreProvider, {
		store = self.flake.store
	}, {
		Roact.createElement(flakeContext.Provider, {
			value = self.flake
		}, {
			Roact.createElement(App)
		})
	})
	Roact.mount(app, gui)

	self:log("initialized")
end

function userInterface:addAppComponent(component: any)
    self.flake.store:dispatch(AddAppComponent(component))
end

function userInterface:addTouchMenuItem(item: types.touchMenuItem)
    self.flake.store:dispatch(AddTouchMenuItem(item))
end

function userInterface:updateTouchMenu()
	if UserInputService.TouchEnabled and self.flake.permissions:getLevel() >= 1 then
		self:log("enabling touch menu")
		self.flake.store:dispatch(SetTouchMenuVisible(true))
	else
		self:log("disabling touch menu")
		self.flake.store:dispatch(SetTouchMenuVisible(false))
	end
end

function userInterface:createPrompt(options: types.promptOptions, windowOptions: types.windowOptions?)
	self.flake.store:dispatch(CreatePrompt({
		id = HttpService:GenerateGUID(),
		options = options,
		window = windowOptions or {}
	}))
end

function userInterface:notify(title: string?, body: string)
	self.flake.store:dispatch(AddNotification({
		id = HttpService:GenerateGUID(),
		title = title,
		body = body,
        endTime = os.time() + 5
	}))
	SoundService:PlayLocalSound(sounds.notify)
end

return userInterface