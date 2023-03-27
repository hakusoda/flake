--!strict
local root = script.Parent.Parent.Parent.Parent.Parent
local libraries = root.libraries
local components = root.userInterface.components

local t = require(root.localisation)()
local types = require(root.types)
local llama = require(libraries.llama)
local Fusion = require(libraries.Fusion)
local Window = require(components.Window)
local AuditLogItem = require(script.Parent.AuditLogItem)

local New, Children, ForPairs, Computed = Fusion.New, Fusion.Children, Fusion.ForPairs, Fusion.Computed
export type AuditLogProps = {
	data: Fusion.StateObject<{types.auditLog}>,
	visible: Fusion.Value<boolean>
}
return function(props: AuditLogProps)
	local data = Computed(function()
		return llama.List.reverse(props.data:get())
	end)
	return Window {
		title = t("audit-log"),
		width = 512,
		height = 312,
		visible = props.visible,
		[Children] = New "ScrollingFrame" {
			Size = UDim2.fromScale(1, 1),
			CanvasSize = UDim2.fromScale(1, 1),
			Transparency = 1,
			ScrollBarThickness = 4,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarImageColor3 = Color3.new(1, 1, 1),
			[Children] = ForPairs(data, function(key, item)
				return key, AuditLogItem {
					key = key,
					data = item
				}
			end, Fusion.cleanup)
		}
	}
end