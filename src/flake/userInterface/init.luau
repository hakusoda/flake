--!strict
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local root = script.Parent
local sounds = script.sounds
local classes = root.classes
local libraries = root.libraries
local components = script.components

local App = require(components.App)
local types = require(root.types)
local llama = require(libraries.llama)
local Fusion = require(libraries.Fusion)
local TouchMenu = require(components.TouchMenu)
local FlakeInfo = require(components.FlakeInfo)
local baseSystem = require(classes.baseSystem)
local CommandBar = require(components.CommandBar)
local CommandList = require(components.CommandList)
local Notifications = require(components.Notifications)

local New, Ref, Value, Children, OnChange = Fusion.New, Fusion.Ref, Fusion.Value, Fusion.Children, Fusion.OnChange

local userInterface: types.userInterface = setmetatable({}, baseSystem) :: any
userInterface.__index = userInterface :: any
userInterface.name = "userInterface"

userInterface.components = components

function userInterface.new(flake: types.flake)
	local self: any = setmetatable(baseSystem.new(flake), userInterface :: any)
	self.emoji = "💻"
	self.prompts = Value({})
	self.notifications = Value({})
	self.appComponents = Value({})
	self.touchMenuItems = Value({})
	self.touchMenuVisible = Value(false)
	self.flakeInfoVisible = Value(false)
	self.commandBarVisible = Value(false)
	self.commandListVisible = Value(false)

	return self
end

function userInterface:initialize()
	local self = self :: types.userInterface

	local gui = Value((nil :: any) :: ScreenGui)
	New "ScreenGui" {
		Name = "flakeInterface",
		Parent = self.flake.player:WaitForChild("PlayerGui"),
		DisplayOrder = 2147483647,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		[Ref] = gui,
		[Children] = App { flake = self.flake },
		[OnChange "Enabled"] = function()
			gui:get().Enabled = true
		end
	}

	UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean)
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
	self:addAppComponent(FlakeInfo)
	self:addAppComponent(CommandBar)
	self:addAppComponent(CommandList)
	self:addAppComponent(Notifications)

	self:addTouchMenuItem({
		icon = "rbxassetid://11568197675",
		onClick = function()
			self.commandBarVisible:set(true)
		end
	})
	self:addTouchMenuItem({
		icon = "rbxassetid://11568098452",
		onClick = function()
			self.flakeInfoVisible:set(true)
		end
	})

	self:log("initialized")
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
		id = HttpService:GenerateGUID(),
		body = options.body,
		title = options.title,
		cancelButton = options.cancelButton,
		confirmButton = options.confirmButton
	}
	list:set(llama.List.join(list:get(), {data}))
end

function userInterface:notify(title: string?, body: string, icon: string | types.notificationIcon | nil)
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
		endTime = os.time() + 5
	}
	list:set(llama.List.join(list:get(), {data}))
	SoundService:PlayLocalSound(sounds.notify)
	
	task.wait(8)
	list:set(llama.List.removeValue(list:get(), data))
end

return userInterface