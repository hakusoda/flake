--!strict
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local root = script.Parent.Parent
local module = root.Parent
local actions = root:WaitForChild("actions")
local libraries = module:WaitForChild("libraries")

local vring = require(libraries:WaitForChild("vring"))
local Roact = require(libraries:WaitForChild("roact-compat"))
local RoactRodux = require(libraries:WaitForChild("roact-rodux"))
local RemoveNotification = require(actions:WaitForChild("RemoveNotification"))

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
                motor:setTarget(3.8)
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
			BackgroundColor3 = Color3.fromRGB(50, 50, 50),
			[Roact.Ref] = container
		}, {
			createElement("UICorner", {
				CornerRadius = UDim.new(0, 8)
			}),
			createElement("UIStroke", {
				Color = Color3.fromRGB(80, 80, 80),
				Thickness = 2
			}),
			createElement("UIGradient", {
				Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(203, 211, 226)),
				Rotation = 90
			}),
			createElement("UIPadding", {
				PaddingTop = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 12),
				PaddingRight = UDim.new(0, 12),
				PaddingBottom = UDim.new(0, 8)
			}),
			createElement("UIListLayout", {
				Padding = UDim.new(0, 12),
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
					FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Medium),
					TextColor3 = Color3.new(1, 1, 1),
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundTransparency = 1
				}),
				createElement("TextLabel", {
					Text = props.data.body or "Notification body",
					TextSize = 12,
					RichText = true,
					FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
					TextColor3 = Color3.fromRGB(230, 230, 230),
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