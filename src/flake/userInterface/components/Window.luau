--!strict
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local root = script.Parent.Parent
local flake = root.Parent
local sounds = root.sounds
local libraries = flake.libraries

local Fusion = require(libraries.Fusion)

local camera = workspace.CurrentCamera
local New, Value, Spring, OnEvent, Cleanup, OnChange, Children, Computed, Observer = Fusion.New, Fusion.Value, Fusion.Spring, Fusion.OnEvent, Fusion.Cleanup, Fusion.OnChange, Fusion.Children, Fusion.Computed, Fusion.Observer

export type WindowButtonProps = {
	onClick: () -> ()
}
function WindowButton(props: WindowButtonProps)
	return New "TextButton" {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(45, 45, 45),
		[Children] = {
			New "UICorner" {
				CornerRadius = UDim.new(0.5, 0)
			},
			New "UIPadding" {
				PaddingTop = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 8)
			},
			props[Children]
		},
		[OnEvent "Activated"] = props.onClick
	}
end

export type WindowProps = {
	title: string,
	width: number?,
	height: number?,
	onClose: () -> (),
	visible: Fusion.StateObject<boolean>?,
	position: UDim2?
}
return function(props: WindowProps)
	local viewportSize = camera.ViewportSize
	
	local render = Value(false)
	local alpha = Computed(function()
		if render:get() then
			local visible = props.visible
			if visible then
				return visible:get() and 1 or 0
			end
			return 1
		end
		return 0
	end)
	local dragging = Value(false)
	local position = Value(props.position or UDim2.fromOffset(viewportSize.X / 2, viewportSize.Y / 2))
	local mouseOffset = Value(Vector2.new())
	local dragConnection = RunService.RenderStepped:Connect(function()
		if dragging:get() then
			local pos = UserInputService:GetMouseLocation()
			local offset = mouseOffset:get()
			position:set(UDim2.fromOffset(pos.X + offset.X, pos.Y + offset.Y))
		end
	end)
	local inputConnection = UserInputService.InputEnded:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging:set(false)
		end
	end)
	local alphaSpring = Spring(alpha, 24)
	local positionSpring = Spring(position, 32, 0.9)
	
	local lastAlpha = 0
	local disconnectAlpha = Observer(alpha):onChange(function()
		local value = alpha:get()
		if value == 1 and lastAlpha == 0 then
			SoundService:PlayLocalSound(sounds.windowOpen)
		end
		lastAlpha = value
	end)
	
	render:set(true)
	
	local Window = New "CanvasGroup" {
		Size = UDim2.fromOffset(props.width or 450, props.height or 300),
		Position = positionSpring,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(36, 36, 36),
		GroupTransparency = Computed(function()
			return 1 - alphaSpring:get()
		end),
		[Cleanup] = { dragConnection, inputConnection, disconnectAlpha },
		[OnChange "Visible"] = function(visible: boolean)
			if visible then
				position:set(UDim2.fromOffset(viewportSize.X / 2, viewportSize.Y / 2))
			end
		end,
		[Children] = {
			New "UIScale" {
				Scale = Computed(function()
					local alpha = alphaSpring:get()
					-- checking if alpha is greater than 0.99
					-- because fusion currently has a bug where
					-- springs do not fully reach their goal,
					-- resulting in the gui element becoming blurry.
					return 0.5 + 0.5 * (alpha > 0.99 and 1 or alpha)
				end)
			},
			New "UICorner" { CornerRadius = UDim.new(0, 16) },
			New "TextButton" {
				Text = "",
				Size = UDim2.new(1, 0, 0, 40),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				[Children] = {
					New "TextLabel" {
						Size = UDim2.fromScale(0, 1),
						Text = props.title or "Window title",
						TextSize = 16,
						Position = UDim2.fromOffset(16, 0),
						FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Medium),
						TextColor3 = Color3.fromRGB(240, 240, 240),
						AutomaticSize = Enum.AutomaticSize.X,
						BackgroundTransparency = 1
					},

					New "Frame" {
						Position = UDim2.new(1, -10, 0.5, 0),
						AnchorPoint = Vector2.new(1, 0.5),
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,
						[Children] = {
							New "UIListLayout" {
								Padding = UDim.new(0, 16)
							},
							WindowButton {
								onClick = function()
									SoundService:PlayLocalSound(sounds.buttonPress)
									props.onClose()
								end,
								[Children] = New "ImageLabel" {
									Size = UDim2.fromOffset(12, 12),
									Image = "rbxassetid://11249698455",
									ImageColor3 = Color3.fromRGB(140, 140, 140),
									BackgroundTransparency = 1
								}
							}
						}
					}
				},
				[OnEvent "MouseButton1Down"] = function()
					local pos = position:get()
					mouseOffset:set(Vector2.new(pos.X.Offset, pos.Y.Offset) - UserInputService:GetMouseLocation())
					dragging:set(true)
				end
			},
			New "Frame" {
				Size = UDim2.new(1, 0, 1, -40),
				Position = UDim2.fromOffset(0, 40),
				BackgroundTransparency = 1,
				[Children] = {
					New "UIPadding" {
						PaddingTop = UDim.new(0, 8),
						PaddingLeft = UDim.new(0, 16),
						PaddingRight = UDim.new(0, 16),
						PaddingBottom = UDim.new(0, 16)
					},
					props[Children]
				}
			}
		}
	}
	return Computed(function()
		if alphaSpring:get() < 0.01 then
			return nil :: any
		end
		return Window
	end, Fusion.doNothing)
end