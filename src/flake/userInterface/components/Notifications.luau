--!strict
local root = script.Parent.Parent.Parent
local libraries = root.libraries
local components = script.Parent

local types = require(root.types)
local Fusion = require(libraries.Fusion)
local Notification = require(components.Notification)

local New, Children, Computed, ForValues = Fusion.New, Fusion.Children, Fusion.Computed, Fusion.ForValues
export type NotificationsProps = {
	flake: types.flake
}
return function(props: NotificationsProps)
	local items = props.flake.userInterface.notifications
	return New "Frame" {
		Size = UDim2.new(1, 0, 1, -32),
		Transparency = 1,
		[Children] = ForValues(items, function(data)
			return Notification {
				data = data,
				position = Computed(function()
					return #items:get() - (table.find(items:get(), data) or 0)
				end)
			}
		end, Fusion.cleanup) :: any
	}
end