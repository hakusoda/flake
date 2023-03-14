--!strict
local root = script.Parent.Parent.Parent
local types = require(root.types)
local libraries = root.libraries

local Fusion = require(libraries.Fusion)

local New, Value, Tween, Spring, Children, Computed = Fusion.New, Fusion.Value, Fusion.Tween, Fusion.Spring, Fusion.Children, Fusion.Computed
export type NotificationProps = {
	data: types.notification,
	position: Fusion.StateObject<number>
}
return function(props: NotificationProps)
	local data = props.data
	local alpha = Value(0)
	local alpha2 = Value(0)
	local posSpring = Spring(props.position, 16, 1)
	local alphaSpring = Tween(alpha, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
	local alpha2Spring = Tween(alpha2, TweenInfo.new(2, Enum.EasingStyle.Quart, Enum.EasingDirection.In))
	task.delay(0.1, alpha.set, alpha, 1)
	task.delay(data.timeLength, alpha2.set, alpha2, 1)
	
	return New "Frame" {
		Size = UDim2.fromOffset(0, 54),
		Position = Computed(function()
			local alpha = alphaSpring:get() - alpha2Spring:get()
			return UDim2.new(1, -16 * alpha, 1, -62 * posSpring:get())
		end),
		AnchorPoint = Computed(function()
			local alpha = alphaSpring:get() - alpha2Spring:get()
			return Vector2.new(alpha, 1)
		end),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.fromRGB(35, 35, 35),
		[Children] = {
			New "UICorner" { CornerRadius = UDim.new(0, 16) },
			New "UIPadding" {
				PaddingTop = UDim.new(0, 12),
				PaddingLeft = UDim.new(0, 20),
				PaddingRight = UDim.new(0, 20),
				PaddingBottom = UDim.new(0, 12)
			},
			New "Frame" {
				Position = UDim2.fromOffset(0, 64),
				Transparency = 1,
				AutomaticSize = Enum.AutomaticSize.X,
				[Children] = {
					New "TextLabel" {
						Size = UDim2.fromOffset(0, 14),
						Text = data.title or "Notification",
						TextSize = 14,
						RichText = true,
						FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Medium),
						TextColor3 = Color3.new(.9, .9, .9),
						AutomaticSize = Enum.AutomaticSize.X,
						BackgroundTransparency = 1
					},
					New "TextLabel" {
						Size = UDim2.fromOffset(0, 12),
						Text = data.body or "Notification body",
						TextSize = 12,
						RichText = true,
						Position = UDim2.fromOffset(0, 18),
						FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
						TextColor3 = Color3.new(.6, .6, .6),
						AutomaticSize = Enum.AutomaticSize.X,
						BackgroundTransparency = 1
					}
				}
			},
			New "Frame" {
				Size = UDim2.fromOffset(32, 32),
				Transparency = 1,
				[Children] = New "ImageLabel" {
					Size = UDim2.fromOffset(32, 32),
					Image = data.icon.image,
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.one / 2,
					ImageColor3 = data.icon.color,
					ImageTransparency = Computed(function()
						return 1 - math.max(alphaSpring:get() - 0.5, 0) / 0.5
					end),
					BackgroundTransparency = 1,
					[Children] = New "UIScale" {
						Scale = Computed(function()
							return 1 + 23 * (1 - math.max(alphaSpring:get() - 0.5, 0) / 0.5)
						end)
					}
				}
			}
		}
	}
end