--!strict
local root = script.Parent.Parent
local flake = root.Parent.Parent.Parent
local libraries = flake.libraries
local components = script.Parent

local t = require(flake.localisation)()
local types = require(flake.types)
local Fusion = require(libraries.Fusion)
local Window = require(flake.userInterface.components.Window)
local interface = require(root.types)
local CommandListItem = require(components.CommandListItem)

local New, Children, Computed, ForPairs = Fusion.New, Fusion.Children, Fusion.Computed, Fusion.ForPairs
export type CommandListProps = {
	flake: types.flake,
	addon: interface.interfaceAddon
}
return function(props: CommandListProps)
	local flake = props.flake
	local interface = props.addon
	
	local commands = Computed(function()
		local list = table.clone(flake.commands.commands:get())
		table.sort(list, function(a, b)
			return a.aliases:get()[1] < b.aliases:get()[1]
		end)
		
		return list
	end)
	return Window {
		title = t("command-list"),
		height = 252,
		visible = interface.commandListVisible,
		[Children] = {
			New "ScrollingFrame" {
				Size = UDim2.new(1, 0, 0, 188),
				Transparency = 1,
				ScrollBarThickness = 4,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarImageColor3 = Color3.new(1, 1, 1),
				[Children] = {
					New "UIListLayout" {
						Padding = UDim.new(0, 8),
						SortOrder = Enum.SortOrder.LayoutOrder
					},
					ForPairs(commands, function(key, command)
						return key, CommandListItem {
							key = key,
							command = command
						}
					end, Fusion.cleanup) :: any
				}
			}
		}
	}
end