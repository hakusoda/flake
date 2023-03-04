--!strict
local root = script.Parent.Parent
local flake = root.Parent.Parent.Parent
local libraries = flake.libraries
local components = script.Parent
local components2 = flake.userInterface.components

local types = require(flake.types)
local Fusion = require(libraries.Fusion)
local Window = require(components2.Window)
local interface = require(root.types)
local InputLabel = require(components2.InputLabel)

local New, Children, Computed, ForValues = Fusion.New, Fusion.Children, Fusion.Computed, Fusion.ForValues
export type CommandListProps = {
	flake: types.flake,
	addon: interface.interfaceAddon
}
return function(props: CommandListProps)
	local flake = props.flake
	local interface = props.addon
	return Window {
		title = "Available Commands",
		height = 256,
		visible = interface.commandListVisible,
		onClose = function()
			interface.commandListVisible:set(false)
		end,
		[Children] = {
			New "ScrollingFrame" {
				Size = UDim2.new(1, 0, 0, 188),
				CanvasSize = UDim2.fromScale(0, 0),
				BorderSizePixel = 0,
				ScrollBarThickness = 8,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarImageColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 1,
				[Children] = {
					New "UIListLayout" { Padding = UDim.new(0, 8) },
					ForValues(flake.commands.commands:get(), function(command)
						return New "Frame" {
							Size = UDim2.fromScale(1, 0),
							AutomaticSize = Enum.AutomaticSize.Y,
							BackgroundColor3 = Color3.fromRGB(45, 45, 45),
							[Children] = {
								New "UICorner" {},
								New "UIPadding" {
									PaddingTop = UDim.new(0, 6),
									PaddingLeft = UDim.new(0, 8),
									PaddingRight = UDim.new(0, 8),
									PaddingBottom = UDim.new(0, 6)
								},
								New "TextLabel" {
									Text = Computed(function()
										local aliases = command.aliases:get()
										return string.format("%s%s(%s)", aliases[1] or "", aliases[2] and (", "..aliases[2].." ") or " ", command.id)
									end),
									TextSize = 12,
									FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
									TextColor3 = Color3.new(.9, .9, .9),
									AutomaticSize = Enum.AutomaticSize.XY,
									BackgroundTransparency = 1
								}
							}
						}
					end, Fusion.cleanup) :: any
				}
			}
		}
	}
end