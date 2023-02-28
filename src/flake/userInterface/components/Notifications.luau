--!strict
local root = script.Parent.Parent
local flake = root.Parent
local libraries = flake.libraries
local components = script.Parent

local types = require(flake.types)
local llama = require(libraries.llama)
local Fusion = require(libraries.Fusion)
local Notification = require(components.Notification)

local New, Ref, Value, Children, ForValues = Fusion.New, Fusion.Ref, Fusion.Value, Fusion.Children, Fusion.ForValues
export type NotificationsProps = {
	flake: types.flake
}
return function(props: NotificationsProps)
	local frameRef = Value(nil)
	local function updateOrder()
		local frame = frameRef:get()
		if frame then
			local height = 0
			for _,child in llama.List.reverse(frame:GetChildren()) do
				if child:IsA("Frame") and child.Visible then
					child.Position = UDim2.new(0, 0, 1, -height)
					height += child.AbsoluteSize.Y + 8
				end
			end
		end
	end

	return New "Frame" {
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromOffset(0, -16),
		BackgroundTransparency = 1,
		[Ref] = frameRef,
		[Children] = {
			New "UIPadding" {
				PaddingTop = UDim.new(0, 2),
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2)
			},
			ForValues(props.flake.userInterface.notifications, function(data)
				return Notification {
					data = data,
					update = updateOrder
				}
			end) :: any
		}
	}
end