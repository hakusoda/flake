--!strict
local root = script.Parent.Parent.Parent
local libraries = root.libraries
local components = script.Parent

local Text = require(components.Text)
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
			Text(data.title or "Notification", 14, UDim2.fromOffset(64, 12), nil, true),
			Text(data.body, 12, UDim2.fromOffset(64, 30), nil),
			New "ImageLabel" {
				Size = UDim2.fromOffset(32, 32),
				Image = data.icon.image,
				Position = UDim2.fromOffset(16, 12),
				ImageColor3 = data.icon.color,
				Transparency = 1
			}
		}
	}
end