--!strict
local root = script.Parent.Parent
local flake = root.Parent.Parent.Parent
local libraries = flake.libraries
local components = flake.userInterface.components

local types = require(flake.types)
local Fusion = require(libraries.Fusion)
local Window = require(components.Window)
local interface = require(root.types)

local New, Children, Computed, ForValues = Fusion.New, Fusion.Children, Fusion.Computed, Fusion.ForValues
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
		title = "Available Commands",
		height = 252,
		visible = interface.commandListVisible,
		onClose = function()
			interface.commandListVisible:set(false)
		end,
		[Children] = {
			New "ScrollingFrame" {
				Size = UDim2.new(1, 0, 0, 188),
				CanvasSize = UDim2.fromScale(0, 0),
				Transparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 8,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarImageColor3 = Color3.new(1, 1, 1),
				[Children] = {
					New "UIListLayout" { Padding = UDim.new(0, 8) },
					ForValues(commands, function(command)
						return New "TextLabel" {
							Size = UDim2.fromScale(1, 0),
							Text = Computed(function()
								local aliases = command.aliases:get()
								return string.format("%s%s(%s)", aliases[1] or "", aliases[2] and (", "..aliases[2].." ") or " ", command.id)
							end),
							TextSize = 12,
							FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
							TextColor3 = Color3.new(.9, .9, .9),
							AutomaticSize = Enum.AutomaticSize.Y,
							TextXAlignment = Enum.TextXAlignment.Left,
							BackgroundColor3 = Color3.fromRGB(45, 45, 45),
							[Children] = {
								New "UICorner" {},
								New "UIPadding" {
									PaddingTop = UDim.new(0, 6),
									PaddingLeft = UDim.new(0, 8),
									PaddingRight = UDim.new(0, 8),
									PaddingBottom = UDim.new(0, 6)
								}
							}
						}
					end, Fusion.cleanup) :: any
				}
			}
		}
	}
end