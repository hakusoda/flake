--!strict
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local root = script.Parent.Parent
local flake = root.Parent
local types = require(flake.types)
local libraries = flake.libraries

local Fusion = require(libraries.Fusion)

local New, Ref, Value, Tween, Cleanup, Children, Computed, Observer = Fusion.New, Fusion.Ref, Fusion.Value, Fusion.Tween, Fusion.Cleanup, Fusion.Children, Fusion.Computed, Fusion.Observer
function getVal(alpha: number, style: Enum.EasingStyle?)
	return TweenService:GetValue(alpha, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
end

export type NotificationProps = {
	data: types.notification,
	update: () -> ()
}
return function(props: NotificationProps)
	local data = props.data
	local alpha = Value(0)
	local tweenInfo = Value(TweenInfo.new(1, Enum.EasingStyle.Linear))
	local alphaSpring = Tween(alpha, tweenInfo :: any)
	local disconnectSpring = Observer(alphaSpring):onChange(function()
		props.update()
	end)
	local visible = Computed(function()
		local value = alphaSpring:get()
		return value > 0 and value < 3.79
	end)
	alpha:set(1.8)
	
	local timerConn = RunService.RenderStepped:Connect(function(deltaTime: number)
		if os.time() >= props.data.endTime and alpha:get() ~= 3.8 then
			tweenInfo:set(TweenInfo.new(2, Enum.EasingStyle.Linear))
			alpha:set(3.8)
		end
	end)
	
	local container = Value(nil)
	return Computed(function()
		if not visible:get() then
			return nil :: any
		end
		
		return New "Frame" {
			Size = Computed(function()
				local alpha = alphaSpring:get()
				local container = container:get()
				if container then
					return UDim2.fromScale(1, 0):Lerp(
						UDim2.new(1, 4, 0, container.AbsoluteSize.Y + 4),
						getVal(math.min(alpha, 1), Enum.EasingStyle.Quart)
					)
				end
				return UDim2.fromScale(1, 0)
			end),
			Position = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			[Cleanup] = { timerConn, disconnectSpring },
			[Children] = {
				New "Frame" {
					Position = Computed(function()
						local alpha = alphaSpring:get()
						return UDim2.new(1, 4, 0, 0):Lerp(UDim2.new(1, -20, 0, 0), getVal(alpha > 1.8 and 1 - (alpha - 1.8) / 2 or math.max(alpha - 0.8, 0) / 0.8, alpha > 1.8 and Enum.EasingStyle.Quad or nil))
					end),
					AnchorPoint = Computed(function()
						local alpha = alphaSpring:get()
						return Vector2.new(0, 0):Lerp(Vector2.new(1, 0), getVal(alpha > 1.8 and 1 - (alpha - 1.8) / 2 or math.max(alpha - 0.8, 0) / 0.8, alpha > 1.8 and Enum.EasingStyle.Quad or nil))
					end),
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundColor3 = Color3.fromRGB(36, 36, 36),
					[Ref] = container,
					[Children] = {
						New "UICorner" {
							CornerRadius = UDim.new(0, 16)
						},
						New "UIPadding" {
							PaddingTop = UDim.new(0, 12),
							PaddingLeft = UDim.new(0, 20),
							PaddingRight = UDim.new(0, 20),
							PaddingBottom = UDim.new(0, 12)
						},
						New "UIListLayout" {
							Padding = UDim.new(0, 32),
							FillDirection = Enum.FillDirection.Horizontal
						},
						New "Frame" {
							AutomaticSize = Enum.AutomaticSize.XY,
							BackgroundTransparency = 1,
							[Children] = {
								New "UIListLayout" {
									Padding = UDim.new(0, 4),
									FillDirection = Enum.FillDirection.Vertical
								},
								New "TextLabel" {
									Text = data.title or "Notification",
									TextSize = 14,
									RichText = true,
									FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Medium),
									TextColor3 = Color3.new(.9, .9, .9),
									AutomaticSize = Enum.AutomaticSize.XY,
									BackgroundTransparency = 1
								},
								New "TextLabel" {
									Text = data.body or "Notification body",
									TextSize = 12,
									RichText = true,
									FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
									TextColor3 = Color3.new(.6, .6, .6),
									AutomaticSize = Enum.AutomaticSize.XY,
									BackgroundTransparency = 1
								}
							}
						},
						New "Frame" {
							Size = UDim2.fromOffset(32, 32),
							BackgroundTransparency = 1,
							[Children] = New "ImageLabel" {
								Size = UDim2.fromOffset(32, 32),
								Image = data.icon or "rbxassetid://7733658504",
								Position = UDim2.fromScale(0.5, 0.5),
								AnchorPoint = Vector2.new(0.5, 0.5),
								ImageColor3 = Color3.new(.9, .9, .9),
								ImageTransparency = Computed(function()
									local alpha = alphaSpring:get()
									return 0.75 + ((0 - 0.75) * getVal(math.max(alpha - 1.2, 0) / 0.6))
								end),
								BackgroundTransparency = 1,
								[Children] = New "UIScale" {
									Scale = Computed(function()
										local alpha = alphaSpring:get()
										return 8 + ((1 - 8) * getVal(math.max(alpha - 1.2, 0) / 0.6))
									end)
								}
							}
						}
					}
				}
			}
		}
	end, Fusion.cleanup)
end