--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local root = script.Parent.Parent
local flake = root.Parent
local sounds = root.sounds
local libraries = flake.libraries
local playerGui: PlayerGui = RunService:IsClient() and Players.LocalPlayer.PlayerGui or nil

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
			New "UICorner" { CornerRadius = UDim.new(0.5, 0) },
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
	local width, height = props.width or 450, props.height or 300
	local initialSize = UDim2.fromOffset(width, height)
	
	local size = Value(initialSize)
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
	local bounds = Rect.new()
	local position = Value(props.position or UDim2.fromOffset(math.max(viewportSize.X / 2, width / 2), math.max(viewportSize.Y / 2, height / 2)))
	local isFitting = Value(false)
	
	local lastViewportSize = viewportSize
	local renderer = RunService.PreRender:Connect(function()
		local currentSize = size:get()
		local viewportSize = camera.ViewportSize
		local viewportDelta = (viewportSize - lastViewportSize) / 2
		if viewportDelta.Magnitude ~= 0 then
			local pos = position:get()
			position:set(UDim2.fromOffset(pos.X.Offset + viewportDelta.X, pos.Y.Offset + viewportDelta.Y))
		end
		lastViewportSize = viewportSize
		
		local isVertical = playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.Portrait
		if isVertical then
			if currentSize.X.Offset ~= viewportSize.X then
				currentSize = UDim2.fromOffset(viewportSize.X, height)
				
				size:set(currentSize)
				position:set(UDim2.fromOffset(viewportSize.X / 2, viewportSize.Y / 2))
				isFitting:set(true)
			end
		else
			local width, height = math.min(width, viewportSize.X), math.min(height, viewportSize.Y)
			local newSize = UDim2.fromOffset(width, height)
			if currentSize ~= newSize then
				currentSize = newSize

				size:set(newSize)
				position:set(UDim2.fromOffset(viewportSize.X / 2, viewportSize.Y / 2))
				isFitting:set(width == viewportSize.X or height == viewportSize.Y)
			end
		end
	end)
	
	local dragging = false
	local dragStart = Vector3.zero
	local dragInput = nil :: InputObject?
	local dragStart2 = UDim2.new()
	local dragPrepare = false
	local inputHandler = UserInputService.InputChanged:Connect(function(input: InputObject)
		if alpha:get() == 1 then
			if dragPrepare then
				dragging = true
				dragPrepare = false

				dragStart = input.Position
				dragStart2 = position:get()
			end

			if dragging and input == dragInput then
				local size = size:get()
				local isVertical = playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.Portrait
				local viewportSize = camera.ViewportSize
				
				local min = Vector2.new(size.X.Offset / 2, size.Y.Offset / 2)
				local max = viewportSize.Magnitude == 0 and min or Vector2.new(viewportSize.X - size.X.Offset / 2, viewportSize.Y - size.Y.Offset / 2)
				bounds = Rect.new(min, max)

				local start = dragStart2
				local delta = input.Position - dragStart
				position:set(UDim2.fromOffset(
					isVertical and min.X or math.clamp(start.X.Offset + delta.X, min.X, max.X),
					math.clamp(start.Y.Offset + delta.Y, min.Y, max.Y)
				))
			end
		end
	end)
	local inputHandler2 = UserInputService.InputEnded:Connect(function(input: InputObject)
		local type = input.UserInputType
		if type == Enum.UserInputType.MouseButton1 or type == Enum.UserInputType.Touch then
			dragging = false
			dragInput = nil
			dragPrepare = false
		end
	end)
	
	local alphaSpring = Spring(alpha, 24)
	local positionSpring = Spring(position, 32, 1)
	
	local lastAlpha = 0
	local alphaObserver = Observer(alpha):onChange(function()
		local value = alpha:get()
		if value == 1 and lastAlpha == 0 then
			SoundService:PlayLocalSound(sounds.windowOpen)
		end
		lastAlpha = value
	end)
	render:set(true)
	
	local Window = New "CanvasGroup" {
		Size = size,
		Position = positionSpring,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(36, 36, 36),
		GroupTransparency = Computed(function()
			return 1 - alphaSpring:get()
		end),
		[Cleanup] = { renderer, inputHandler, inputHandler2, alphaObserver },
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
			New "UICorner" {
				CornerRadius = Computed(function()
					return UDim.new(0, isFitting:get() and 0 or 16)
				end)
			},
			New "TextButton" {
				Text = "",
				Size = UDim2.new(1, 0, 0, 40),
				Transparency = 1,
				BorderSizePixel = 0,
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
						Transparency = 1,
						AutomaticSize = Enum.AutomaticSize.XY,
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
									Transparency = 1
								}
							}
						}
					}
				},
				[OnEvent "InputBegan"] = function(input: InputObject)
					if alpha:get() == 1 then
						local type = input.UserInputType
						if type == Enum.UserInputType.MouseButton1 or type == Enum.UserInputType.Touch then
							dragPrepare = true
						end
					end
				end,
				[OnEvent "InputChanged"] = function(input: InputObject)
					if alpha:get() == 1 then
						if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
							dragInput = input
						end
					end
				end
			},
			New "Frame" {
				Size = UDim2.new(1, 0, 1, -40),
				Position = UDim2.fromOffset(0, 40),
				Transparency = 1,
				ClipsDescendants = true,
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
		if alphaSpring:get() < 0.02 then
			return nil :: any
		end
		return Window
	end, Fusion.doNothing)
end