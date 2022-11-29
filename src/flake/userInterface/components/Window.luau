--!strict
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local root = script.Parent.Parent
local flake = root.Parent
local sounds = root.sounds
local libraries = flake.libraries

local vring = require(libraries.vring)
local Roact = require(libraries["roact-compat"])

local camera = workspace.CurrentCamera
local useRef, useMemo, useState, useEffect, createElement = Roact.useRef, Roact.useMemo, Roact.useState, Roact.useEffect, Roact.createElement
function WindowButton(props)
    return createElement("TextButton", {
        Text = "",
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        [Roact.Event.Activated] = props.onClick
    }, {
        createElement("UICorner", {
            CornerRadius = UDim.new(0.5, 0)
        }),
        createElement("UIPadding", {
            PaddingTop = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8)
        }),
        table.unpack(props.children)
    })
end

return function(props)
    local viewportSize = camera.ViewportSize

    local alpha, setAlpha = useState(0)
    local width, setWidth = useState(props.width or 400)
    local height, setHeight = useState(props.height or 300)
    local visible, setVisible = useState(false)
    local dragging = useRef(false)
    local position, setPosition = useState(props.position or UDim2.fromOffset(
        viewportSize.X / 2,
        viewportSize.Y / 2
    ))
    local mouseOffset = useRef(Vector2.new())
    local inputConnection = useMemo(function()
        return UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessed: boolean)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging.current = false
            end
        end)
    end, {})
    local motor, positionMotors = useMemo(function()
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
        :connectStepper(RunService.Stepped),
        --TODO: switch to linearMotor when it supports vector2
        vring.motorGroup.new()
        :add("x", vring.linearMotor.new(viewportSize.X / 2))
        :add("y", vring.linearMotor.new(viewportSize.Y / 2))
        :onStep(function(values)
            setPosition(UDim2.fromOffset(values.x, values.y))
        end)
        :onStepper(function(group)
            if dragging.current then
                local offset = mouseOffset.current
                local position = UserInputService:GetMouseLocation()
                group:get("x"):setTarget(position.X + offset.X):setLength(0.1)
                group:get("y"):setTarget(position.Y + offset.Y):setLength(0.1)
            end
        end)
        :connectStepper(RunService.Stepped)
    end, {})
    useEffect(function()
        return function()
            motor:destroy()
            positionMotors:destroy()
            inputConnection:Disconnect()
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
		Size = UDim2.fromOffset(props.width or 450, props.height or 300),
		Position = position,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(36, 36, 36),
		GroupTransparency = 1 - alpha
	}, {
		createElement("UIScale", {
			Scale = 0.5 + (0.5 * TweenService:GetValue(alpha, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
		}),
		createElement("UICorner", {
			CornerRadius = UDim.new(0, 16)
		}),
		createElement("TextButton", {
            Text = "",
			Size = UDim2.new(1, 0, 0, 40),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
            [Roact.Event.MouseButton1Down] = function()
                mouseOffset.current = Vector2.new(position.X.Offset, position.Y.Offset) - UserInputService:GetMouseLocation()
                dragging.current = true
            end
		}, {
			createElement("TextLabel", {
				Size = UDim2.fromScale(0, 1),
				Text = props.title or "Window title",
				TextSize = 16,
				Position = UDim2.fromOffset(16, 0),
				FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Medium),
				TextColor3 = Color3.fromRGB(240, 240, 240),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1
			}),

            createElement("Frame", {
                Position = UDim2.new(1, -10, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundTransparency = 1
            }, {
                createElement("UIListLayout", {
                    Padding = UDim.new(0, 16)
                }),
                createElement(WindowButton, {
                    onClick = function()
                        SoundService:PlayLocalSound(sounds.buttonPress)
                        props.onClose()
                    end
                }, {
                    createElement("ImageLabel", {
                        Size = UDim2.fromOffset(12, 12),
                        Image = "rbxassetid://11249698455",
                        ImageColor3 = Color3.fromRGB(140, 140, 140),
                        BackgroundTransparency = 1
                    })
                })
            })
		}),
		createElement("Frame", {
			Size = UDim2.new(1, 0, 1, -40),
			Position = UDim2.fromOffset(0, 40),
			BorderSizePixel = 0,
			BackgroundTransparency = 1
		}, {
			createElement("UIPadding", {
				PaddingTop = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 16),
				PaddingRight = UDim.new(0, 16),
				PaddingBottom = UDim.new(0, 16)
			}),
			table.unpack(props.children)
		})
	})
end