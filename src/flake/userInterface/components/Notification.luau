--!strict
local TextService = game:GetService("TextService")

local root = script.Parent.Parent.Parent
local types = require(root.types)
local libraries = root.libraries

local t = require(root.localisation)()
local Fusion = require(libraries.Fusion)

local New, Value, Tween, Spring, Children, Computed = Fusion.New, Fusion.Value, Fusion.Tween, Fusion.Spring, Fusion.Children, Fusion.Computed
local params = Instance.new("GetTextBoundsParams")
params.Font = Font.fromName("GothamSSm")

function getBounds(text: types.translatable, size: number): Fusion.StateObject<Vector2>
	if typeof(text) == "string" then
		params.Size = size
		params.Text = string.gsub(text, "<.->", "")
		return Value(TextService:GetTextBoundsAsync(params))
	else
		return Computed(function()
			params.Size = size
			params.Text = string.gsub(text:get(), "<.->", "")
			return TextService:GetTextBoundsAsync(params)
		end)
	end
end

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
	
	local textBounds1 = getBounds(data.title or "Notification", 14)
	local textBounds2 = getBounds(data.body or "Notification body", 12)
	
	local textWidth = Computed(function()
		return math.max(textBounds1:get().X, textBounds2:get().X)
	end)
	return New "Frame" {
		Size = Computed(function()
			return UDim2.fromOffset(textWidth:get() + 96, 54)
		end),
		Position = Computed(function()
			local alpha = alphaSpring:get() - alpha2Spring:get()
			return UDim2.new(1, -16 * alpha, 1, -62 * posSpring:get() - 32)
		end),
		AnchorPoint = Computed(function()
			local alpha = alphaSpring:get() - alpha2Spring:get()
			return Vector2.new(alpha, 1)
		end),
		BackgroundColor3 = Color3.fromRGB(35, 35, 35),
		[Children] = {
			New "UICorner" { CornerRadius = UDim.new(0, 16) },
			New "UIPadding" {
				PaddingTop = UDim.new(0, 12),
				PaddingLeft = UDim.new(0, 20),
				PaddingRight = UDim.new(0, 20),
				PaddingBottom = UDim.new(0, 12)
			},
			New "TextLabel" {
				Size = Computed(function()
					return UDim2.fromOffset(textBounds1:get().X, 14)
				end),
				Text = data.title or "Notification",
				TextSize = 14,
				RichText = true,
				FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Medium),
				TextColor3 = Color3.new(.9, .9, .9),
				BackgroundTransparency = 1
			},
			New "TextLabel" {
				Size = Computed(function()
					return UDim2.fromOffset(textBounds2:get().X, 12)
				end),
				Text = data.body or "Notification body",
				TextSize = 12,
				RichText = true,
				Position = UDim2.fromOffset(0, 18),
				FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
				TextColor3 = Color3.new(.6, .6, .6),
				BackgroundTransparency = 1
			},
			New "Frame" {
				Size = UDim2.fromOffset(32, 32),
				Position = Computed(function()
					return UDim2.fromOffset(textWidth:get() + 24, 0)
				end),
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