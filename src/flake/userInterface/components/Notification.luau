--!strict
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local root = script.Parent.Parent
local flake = root.Parent
local actions = flake.store.actions
local libraries = flake.libraries

local vring = require(libraries.vring)
local Roact = require(libraries["roact-compat"])
local RoactRodux = require(libraries["roact-rodux"])
local RemoveNotification = require(actions.RemoveNotification)

local useRef, useMemo, useState, useEffect, createElement = Roact.useRef, Roact.useMemo, Roact.useState, Roact.useEffect, Roact.createElement
return RoactRodux.connect(nil, function(dispatch)
	return { destroy = function(id)
        dispatch(RemoveNotification(id))
    end }
end)(function(props)
    local alpha, setAlpha = useState(0)
    local motor = useMemo(function()
        return vring.linearMotor.new(alpha, 2)
        :onStep(function(value, motor)
            setAlpha(value)
            if value > 0 and value < 3.8 then
                props.update()
            end
            if value == 3.8 then
                motor:destroy()
            end
        end)
        :setTarget(1.8)
        :onStepper(function(motor)
            if props.data.endTime - os.time() <= 0 then
                motor:setTarget(3.8):setVelocity(1.5)
            end
        end)
        :connectStepper(RunService.Stepped)
    end, {}) :: vring.linearMotor
    useEffect(function()
        return function()
            motor:destroy()
        end
    end, {})

    local container = useRef(nil)
    if alpha == 0 or alpha == 3.8 then
        return
    end
    return createElement("Frame", {
		Size = container.current and UDim2.fromScale(1, 0):Lerp(
            UDim2.new(1, 4, 0, container.current.AbsoluteSize.Y + 4),
            TweenService:GetValue(math.min(alpha, 1), Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        ) or UDim2.fromScale(1, 0),
		Position = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1
	}, {
		createElement("Frame", {
			Position = (function() --im lazy
                local value = alpha
				if value > 1.8 then
					value = TweenService:GetValue(
						1 - (value - 1.8) / 2,
						Enum.EasingStyle.Quad, Enum.EasingDirection.Out
					)
				else
					value = TweenService:GetValue(
						math.max(value - 0.8, 0) / 0.8,
						Enum.EasingStyle.Quart, Enum.EasingDirection.Out
					)
				end
				return UDim2.new(1, 4, 0, 0):Lerp(UDim2.new(1, -20, 0, 0), value)
			end)(),
			AnchorPoint = (function() --im lazy
                local value = alpha
				if value > 1.8 then
					value = TweenService:GetValue(
						1 - (value - 1.8) / 2,
						Enum.EasingStyle.Quad, Enum.EasingDirection.Out
					)
				else
					value = TweenService:GetValue(
						math.max(value - 0.8, 0) / 0.8,
						Enum.EasingStyle.Quart, Enum.EasingDirection.Out
					)
				end
				return Vector2.new(0, 0):Lerp(Vector2.new(1, 0), value)
			end)(),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = Color3.fromRGB(36, 36, 36),
			[Roact.Ref] = container
		}, {
			createElement("UICorner", {
				CornerRadius = UDim.new(0, 16)
			}),
			createElement("UIPadding", {
				PaddingTop = UDim.new(0, 12),
				PaddingLeft = UDim.new(0, 20),
				PaddingRight = UDim.new(0, 20),
				PaddingBottom = UDim.new(0, 12)
			}),
			createElement("UIListLayout", {
				Padding = UDim.new(0, 32),
				FillDirection = Enum.FillDirection.Horizontal
			}),
			createElement("Frame", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1
			}, {
				createElement("UIListLayout", {
					Padding = UDim.new(0, 4),
					FillDirection = Enum.FillDirection.Vertical
				}),
				createElement("TextLabel", {
					Text = props.data.title or "Notification header",
					TextSize = 14,
                    RichText = true,
					FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Medium),
					TextColor3 = Color3.new(.9, .9, .9),
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundTransparency = 1
				}),
				createElement("TextLabel", {
					Text = props.data.body or "Notification body",
					TextSize = 12,
					RichText = true,
					FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
					TextColor3 = Color3.new(.6, .6, .6),
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundTransparency = 1
				})
			}),
			createElement("Frame", {
				Size = UDim2.fromOffset(32, 32),
				BackgroundTransparency = 1
			}, {
				createElement("ImageLabel", {
					Size = UDim2.fromOffset(32, 32),
					Image = "rbxassetid://7733658504",
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
                    ImageColor3 = Color3.new(.9, .9, .9),
					ImageTransparency = 0.75 + ((0 - 0.75) * TweenService:GetValue(
                        math.max(alpha - 1.2, 0) / 0.6,
                        Enum.EasingStyle.Quart, Enum.EasingDirection.Out
                    )),
					BackgroundTransparency = 1
				}, {
					createElement("UIScale", {
						Scale = 8 + ((1 - 8) * TweenService:GetValue(
                            math.max(alpha - 1.2, 0) / 0.6,
                            Enum.EasingStyle.Quart, Enum.EasingDirection.Out
                        ))
					})
				})
			})
		})
	})
end)