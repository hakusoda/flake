--!strict
local root = script.Parent.Parent.Parent
local libraries = root.libraries

local types = require(root.types)
local theme = require(root.userInterface.theme)()
local Fusion = require(libraries.Fusion)

local New, Value, Spring, Children, Computed = Fusion.New, Fusion.Value, Fusion.Spring, Fusion.Children, Fusion.Computed
export type MobileNotificationProps = {
	data: types.notification,
	position: Fusion.StateObject<number>,
	interface: types.userInterface
}
return function(props: MobileNotificationProps)
	local data = props.data
	local alpha = Value(0)
	local posSpring = Spring(props.position, 16, 1)
	local alphaSpring = Spring(alpha, 16, 1)
	task.delay(0.1, alpha.set, alpha, 1)
	task.delay(data.timeLength, alpha.set, alpha, 0)

	return New "Frame" {
		Size = UDim2.new(1, -32, 0, 54),
		ZIndex = Computed(function()
			return -props.position:get()
		end),
		Position = Computed(function()
			local alpha = alphaSpring:get()
			return UDim2.new(0, 16, 0, (-props.interface.gui.AbsolutePosition.Y + 16) * alpha + 62 * posSpring:get() * alpha)
		end),
		AnchorPoint = Computed(function()
			local alpha = alphaSpring:get()
			return Vector2.new(0, 1 - alpha)
		end),
		BackgroundColor3 = theme.backgroundPrimary,
		[Children] = {
			New "UICorner" { CornerRadius = UDim.new(0, 16) },
			New "UIPadding" {
				PaddingTop = UDim.new(0, 12),
				PaddingLeft = UDim.new(0, 16),
				PaddingBottom = UDim.new(0, 12)
			},
			New "TextLabel" {
				Size = UDim2.fromOffset(0, 14),
				Text = data.title or "Notification",
				TextSize = 14,
				RichText = true,
				FontFace = theme.font500,
				Position = UDim2.fromOffset(48, 0),
				TextColor3 = theme.textPrimary,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1
			},
			New "TextLabel" {
				Size = UDim2.fromOffset(0, 12),
				Text = data.body or "Notification body",
				TextSize = 12,
				RichText = true,
				FontFace = theme.font400,
				Position = UDim2.fromOffset(48, 18),
				TextColor3 = theme.textPrimary,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1
			},
			New "ImageLabel" {
				Size = UDim2.fromOffset(32, 32),
				Image = data.icon.image,
				ImageColor3 = data.icon.color,
				Transparency = 1
			}
		}
	}
end