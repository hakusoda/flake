--!strict
local root = script.Parent.Parent.Parent
local libraries = root.libraries
local components = script.Parent

local types = require(root.types)
local Fusion = require(libraries.Fusion)
local Notification = require(components.Notification)
local MobileNotification = require(components.MobileNotification)

local New, Children, Computed, ForValues = Fusion.New, Fusion.Children, Fusion.Computed, Fusion.ForValues
export type NotificationsProps = {
	flake: types.flake
}
return function(props: NotificationsProps)
	local interface = props.flake.userInterface
	
	local items = interface.notifications
	return New "Frame" {
		Size = UDim2.fromScale(1, 1),
		Transparency = 1,
		[Children] = ForValues(items, function(data)
			if interface.playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.Portrait then
				return MobileNotification {
					data = data,
					position = Computed(function()
						local items = items:get()
						local pos = (table.find(items, data) or 1) - 1
						for _,item in items do
							if item.exiting:get() then
								pos -= 1
							end
						end
						return pos
					end),
					interface = interface
				}
			else
				return Notification {
					data = data,
					position = Computed(function()
						return #items:get() - (table.find(items:get(), data) or 0)
					end)
				}
			end
		end, Fusion.cleanup) :: any
	}
end