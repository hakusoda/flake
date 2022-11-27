--!strict
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local root = script.Parent
local sounds = script.sounds
local classes = root.classes
local actions = script.actions
local reducers = script.reducers
local libraries = root.libraries
local components = script.components

local App = require(components.App)
local types = require(root.types)
local Rodux = require(libraries.rodux)
local Roact = require(libraries["roact-compat"])
local Reducer = require(reducers.Reducer)
local baseSystem = require(classes.baseSystem)
local RoactRodux = require(libraries["roact-rodux"])
local CreatePrompt = require(actions.CreatePrompt)
local flakeContext = require(components.flakeContext)
local AddNotification = require(actions.AddNotification)
local SetTouchMenuVisible = require(actions.SetTouchMenuVisible)
local SetCommandBarVisible = require(actions.SetCommandBarVisible)
local SetCommandBarCommands = require(actions.SetCommandBarCommands)

local userInterface: types.userInterface = setmetatable({}, baseSystem) :: any
userInterface.__index = userInterface :: any
userInterface.name = "userInterface"

userInterface.components = components

function userInterface.new(flake: types.flake)
	local self: any = setmetatable(baseSystem.new(flake), userInterface :: any)
	self.emoji = "💻"
	self.store = Rodux.Store.new(Reducer, nil, {
		Rodux.thunkMiddleware
	} :: any)

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
				self.store:dispatch(SetCommandBarVisible(true))
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
    self.store:dispatch(SetCommandBarCommands(commandSystem.commands))

	commandSystem:onEvent("COMMAND_CREATED", function()
		self.store:dispatch(SetCommandBarCommands(commandSystem.commands))
	end)

	local app = Roact.createElement(RoactRodux.StoreProvider, {
		store = self.store
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

function userInterface:updateTouchMenu()
	if UserInputService.TouchEnabled and self.flake.permissions:getLevel() >= 1 then
		self:log("enabling touch menu")
		self.store:dispatch(SetTouchMenuVisible(true))
	else
		self:log("disabling touch menu")
		self.store:dispatch(SetTouchMenuVisible(false))
	end
end

function userInterface:createPrompt(options: types.promptOptions, windowOptions: types.windowOptions?)
	self.store:dispatch(CreatePrompt({
		id = HttpService:GenerateGUID(),
		options = options,
		window = windowOptions or {}
	}))
end

function userInterface:notify(title: string?, body: string)
	self.store:dispatch(AddNotification({
		id = HttpService:GenerateGUID(),
		title = title,
		body = body,
        endTime = os.time() + 5
	}))
	SoundService:PlayLocalSound(sounds.notify)
end

return userInterface