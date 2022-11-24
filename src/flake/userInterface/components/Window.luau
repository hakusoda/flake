--!strict
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local root = script.Parent.Parent
local module = root.Parent
local sounds = root.sounds
local libraries = module.libraries

local vring = require(libraries.vring)
local Roact = require(libraries["roact-compat"])

local useMemo, useState, useEffect, createElement = Roact.useMemo, Roact.useState, Roact.useEffect, Roact.createElement
return function(props)
    local alpha, setAlpha = useState(0)
    local visible, setVisible = useState(false)
    local motor = useMemo(function()
        return vring.linearMotor.new(alpha, 4)
        :onStep(function(value)
            setAlpha(value)

            local newVisible = value > 0
            if visible ~= newVisible then
                setVisible(newVisible)

                local changed = props.changed
                if changed then
                    changed()
                end
            end
        end)
        :connectStepper(RunService.Stepped)
    end, {}) :: vring.linearMotor
    useEffect(function()
        return function()
            motor:destroy()
        end
    end, {})
    useEffect(function()
        if not props.hidden and motor.target == 0 then
            SoundService:PlayLocalSound(sounds.windowOpen)
        end
        motor:setTarget(props.hidden and 0 or 1)
    end, {props.hidden})
    if alpha == 0 then
        return
    end

    return createElement("CanvasGroup", {
		Size = UDim2.fromOffset(props.width or 350, props.height or 250),
		Position = (props.position or UDim2.fromScale(0.5, 0.5)) + UDim2.fromOffset(0, 64 * (1 - TweenService:GetValue(alpha, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))),
		AnchorPoint = props.anchor or Vector2.new(0.5, 0.5),
		GroupTransparency = 1 - alpha
	}, {
		createElement("UIScale", {
			Scale = 0.5 + (0.5 * TweenService:GetValue(alpha, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
		}),
		createElement("UICorner", {
			CornerRadius = UDim.new(0, 10)
		}),
		createElement("UIStroke", {
			Color = Color3.fromRGB(80, 80, 80),
			Thickness = 2,
			Transparency = 1 - alpha
		}),
		createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 32),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		}, {
			createElement("ImageLabel", {
				Size = UDim2.fromOffset(24, 24),
				Image = props.icon or "rbxassetid://11242597370",
				Position = UDim2.fromOffset(4, 4),
				BackgroundTransparency = 1
			}),
			createElement("TextLabel", {
				Size = UDim2.fromScale(0, 1),
				Text = props.title or "Window title",
				TextSize = 12,
				Position = UDim2.fromOffset(34, 0),
				FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Medium),
				TextColor3 = Color3.fromRGB(240, 240, 240),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1
			}),

			createElement("ImageButton", {
				Size = UDim2.fromOffset(12, 12),
				Image = "rbxassetid://11249698455",
				Position = UDim2.new(1, -10, 0, 10),
				AnchorPoint = Vector2.new(1, 0),
				ImageColor3 = Color3.fromRGB(240, 240, 240),
				BackgroundTransparency = 1,
				[Roact.Event.Activated] = function()
					SoundService:PlayLocalSound(sounds.buttonPress)
					props.onClose()
				end
			})
		}),
		createElement("Frame", {
			Size = UDim2.new(1, 0, 1, -32),
			Position = UDim2.fromOffset(0, 32),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		}, {
			createElement("UIPadding", {
				PaddingTop = UDim.new(0, 12),
				PaddingLeft = UDim.new(0, 12),
				PaddingRight = UDim.new(0, 12),
				PaddingBottom = UDim.new(0, 12)
			}),
			createElement("UIGradient", {
				Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(203, 211, 226)),
				Rotation = 90
			}),
			table.unpack(props[Roact.Children])
		})
	})
end