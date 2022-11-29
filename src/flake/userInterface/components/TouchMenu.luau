--!strict
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local root = script.Parent.Parent
local flake = root.Parent
local sounds = root.sounds
local actions = flake.store.actions
local libraries = flake.libraries

local llama = require(libraries.llama)
local vring = require(libraries.vring)
local Roact = require(libraries["roact-compat"])
local RoactRodux = require(libraries["roact-rodux"])

local useMemo, useState, useEffect, createElement, createFragment = Roact.useMemo, Roact.useState, Roact.useEffect, Roact.createElement, Roact.createFragment
return RoactRodux.connect(function(state)
	return { items = state.interface.touchMenuItems, visible = true }
end)(function(props)
	local alpha, setAlpha = useState(0)
	local motor = useMemo(function()
		return vring.linearMotor.new(alpha, 4)
		:onStep(setAlpha)
		:connectStepper(RunService.Stepped)
	end, {}) :: vring.linearMotor
	useEffect(function()
		return function()
			motor:destroy()
		end
	end, {})
	if not props.visible then
		return
	end

	return createElement("ImageLabel", {
		Size = UDim2.fromOffset(400, 48),
		Image = "rbxassetid://11568047819",
		Position = UDim2.fromScale(0.5, 0),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(48, 0, 168, 48),
		ImageColor3 = Color3.fromRGB(60, 60, 60),
		AnchorPoint = Vector2.new(0.5, TweenService:GetValue(1 - alpha, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)),
		BackgroundTransparency = 1
	}, {
		alpha >= 0 and createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1
		}, {
			createElement("UIListLayout", {
				Padding = UDim.new(0, 16),
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Center
			}),
			createFragment(llama.List.map(props.items, function(item, key)
				return createElement("ImageButton", {
					Size = UDim2.fromOffset(40, 40),
					Image = item.icon,
					LayoutOrder = key,
					BackgroundTransparency = 1,
					[Roact.Event.Activated] = function()
						SoundService:PlayLocalSound(sounds.buttonPress)
	
						motor:setTarget(0)
						item.onClick()
					end
				})
			end))
		}),
		createElement("ImageButton", {
			Size = UDim2.fromOffset(140, 24),
			Image = "rbxassetid://11568040458",
			Position = UDim2.fromScale(0.5, 1),
			ScaleType = Enum.ScaleType.Slice,
			AnchorPoint = Vector2.new(0.5, 0),
			SliceCenter = Rect.new(24, 0, 84, 24),
			ImageColor3 = Color3.fromRGB(60, 60, 60),
			BackgroundTransparency = 1,
			[Roact.Event.Activated] = function()
				SoundService:PlayLocalSound(sounds.buttonPress)
				motor:setTarget(motor.target == 0 and 1 or 0)
			end
		}, {
			createElement("TextLabel", {
				Text = "flake menu",
				Size = UDim2.fromScale(1, 1),
				TextSize = 14,
				FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Medium),
				TextColor3 = Color3.fromRGB(240, 240, 240),
				BackgroundTransparency = 1
			})
		})
	})
end)