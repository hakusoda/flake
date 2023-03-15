--!strict
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local root = script.Parent
local sounds = script.sounds
local libraries = root.libraries
local components = script.components

local App = require(components.App)
local types = require(root.types)
local llama = require(libraries.llama)
local images = require(script.images)
local Fusion = require(libraries.Fusion)
local TouchMenu = require(components.TouchMenu)
local CommandBar = require(components.CommandBar)
local createSystem = require(root.helpers.createSystem)
local Notifications = require(components.Notifications)

local New, Value, Children, OnChange = Fusion.New, Fusion.Value, Fusion.Children, Fusion.OnChange
local userInterface: types.userInterface, buildSystem = createSystem("userInterface", "💻")
userInterface.components = components

function userInterface.new(flake: types.flake)
	local self = buildSystem(flake)
	self.prompts = Value({})
	self.notifications = Value({})
	self.appComponents = Value({})
	self.touchMenuItems = Value({})
	self.touchMenuVisible = Value(false)
	self.commandBarVisible = Value(false)

	return self
end

function userInterface:initialise()
	local self = self :: types.userInterface
	self.playerGui = self.flake.player:WaitForChild("PlayerGui") :: PlayerGui
	self.gui = New "ScreenGui" {
		Name = "flakeInterface",
		Parent = self.playerGui,
		AutoLocalize = false,
		ResetOnSpawn = false,
		DisplayOrder = 2147483647,
		ScreenInsets = Enum.ScreenInsets.None,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		[Children] = App { flake = self.flake },
		[OnChange "Enabled"] = function()
			self.gui.Enabled = true
		end
	} :: ScreenGui

	UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
		if not gameProcessedEvent then
			local keycode = input.KeyCode
			if keycode == Enum.KeyCode.Comma and (not self.flake.config.hidden or self.flake.permissions:getLevel() > 0) then
				self.commandBarVisible:set(true)
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
	
	self:addAppComponent(TouchMenu)
	self:addAppComponent(CommandBar)
	self:addAppComponent(Notifications)
	
	-- TODO: add more touch menu items
	self:addTouchMenuItem({
		icon = images.COMMAND_BAR_ICON,
		onClick = function()
			self.commandBarVisible:set(true)
		end
	})

	self:log("initialised")
end

function userInterface:addAppComponent(component: any)
	local list = self.appComponents
	list:set(llama.List.join(list:get(), {component}))
end

function userInterface:addTouchMenuItem(item: types.touchMenuItem)
	local list = self.touchMenuItems
	list:set(llama.List.join(list:get(), {item}))
end

function userInterface:updateTouchMenu()
	self.touchMenuVisible:set(UserInputService.TouchEnabled and self.flake.permissions:getLevel() >= 1)
end

function userInterface:createPrompt(options: types.promptOptions, windowOptions: types.windowOptions?)
	local list = self.prompts
	local data: types.prompt = {
		id = HttpService:GenerateGUID(false),
		body = options.body,
		title = options.title,
		cancelButton = options.cancelButton,
		confirmButton = options.confirmButton
	}
	list:set(llama.List.join(list:get(), {data}))
end

function userInterface:notify(title: types.translatable?, body: types.translatable, icon: string | types.notificationIcon | nil)
	local list = self.notifications
	
	local realIcon = icon and llama.Dictionary.join({
		color = Color3.new(1, 1, 1),
		image = typeof(icon) == "string" and icon or ""
	}, typeof(icon) == "table" and icon or nil) or {
		color = Color3.new(.9, .9, .9),
		image = "rbxassetid://7733658504"
	}
	local data: types.notification = {
		id = HttpService:GenerateGUID(),
		body = body,
		icon = realIcon,
		title = title,
		exiting = Value(false),
		timeLength = 5
	}
	list:set(llama.List.join(list:get(), {data}))
	SoundService:PlayLocalSound(sounds.notify)
	
	task.delay(data.timeLength, data.exiting.set, data.exiting, true)
	task.delay(data.timeLength + 2, function()
		list:set(llama.List.removeValue(list:get(), data))
	end)
end

return userInterface