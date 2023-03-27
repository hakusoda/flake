--!strict
local TextService = game:GetService("TextService")

local root = script.Parent.Parent
local flake = root.Parent

local Text = require(script.Parent.Text)
local theme = require(root.theme)()
local types = require(flake.types)
local Fusion = require(flake.libraries.Fusion)

local New, Value, Tween, Spring, Children, Computed = Fusion.New, Fusion.Value, Fusion.Tween, Fusion.Spring, Fusion.Children, Fusion.Computed
function getBounds(text: types.translatable, size: number): Fusion.StateObject<Vector2>
	local params = Instance.new("GetTextBoundsParams")
	params.Size = size
	
	return Computed(function()
		local text = if typeof(text) == "string" then text else text:get()
		params.Font = (theme.font400 :: any):get()
		params.Text = string.gsub(text, "<.->", "")
		return TextService:GetTextBoundsAsync(params)
	end)
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
		BackgroundColor3 = theme.backgroundPrimary,
		[Children] = {
			New "UICorner" { CornerRadius = UDim.new(0, 16) },
			Text(data.title or "Notification", nil, UDim2.fromOffset(20, 12), nil, true),
			Text(data.body, 12, UDim2.fromOffset(20, 30), theme.textSecondary),
			New "Frame" {
				Size = UDim2.fromOffset(32, 32),
				Position = Computed(function()
					return UDim2.fromOffset(textWidth:get() + 44, 12)
				end),
				Transparency = 1,
				[Children] = New "ImageLabel" {
					Size = UDim2.fromOffset(32, 32),
					Image = data.icon.image,
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.one / 2,
					ImageColor3 = data.icon.color,
					Transparency = 1,
					ImageTransparency = Computed(function()
						return 1 - math.max(alphaSpring:get() - 0.5, 0) / 0.5
					end),
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