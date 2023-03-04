--!strict
local root = script.Parent.Parent
local flake = root.Parent.Parent.Parent
local libraries = flake.libraries
local components = script.Parent

local types = require(flake.types)
local Fusion = require(libraries.Fusion)
local Window = require(flake.userInterface.components.Window)
local interface = require(root.types)

local New, Computed, Children, ForValues = Fusion.New, Fusion.Computed, Fusion.Children, Fusion.ForValues
export type AddonProps = {
	addon: types.baseAddon,
	onClose: () -> ()
}
return function(props: AddonProps)
	local addon = props.addon
	return Window {
		title = "About Addon",
		width = 512,
		height = 144,
		onClose = props.onClose,
		visible = Fusion.Value(true),
		[Children] = {
			New "UIListLayout" { Padding = UDim.new(0, 16) },
			New "Frame" {
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = Color3.fromRGB(45, 45, 45),
				[Children] = {
					New "UICorner" {
						CornerRadius = UDim.new(0, 8)
					},
					New "UIPadding" {
						PaddingTop = UDim.new(0, 8),
						PaddingLeft = UDim.new(0, 8),
						PaddingRight = UDim.new(0, 8),
						PaddingBottom = UDim.new(0, 8)
					},
					New "ImageLabel" {
						Size = UDim2.fromOffset(64, 64),
						Image = addon.icon,
						BackgroundTransparency = 1
					},
					New "Frame" {
						Size = UDim2.fromOffset(0, 64),
						Position = UDim2.fromOffset(80, 0),
						BackgroundTransparency = 1,
						[Children] = {
							New "UIListLayout" {
								Padding = UDim.new(0, 4),
								VerticalAlignment = Enum.VerticalAlignment.Center
							},
							New "TextLabel" {
								Text = `{addon.name} <font size=\"12\" color=\"#c8c8c8\">v{addon.version}</font>`,
								TextSize = 16,
								RichText = true,
								FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Medium),
								TextColor3 = Color3.new(.8, .8, .8),
								AutomaticSize = Enum.AutomaticSize.XY,
								BackgroundTransparency = 1
							},
							New "TextLabel" {
								Text = addon.description,
								TextSize = 12,
								FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
								TextColor3 = Color3.new(.6, .6, .6),
								AutomaticSize = Enum.AutomaticSize.XY,
								BackgroundTransparency = 1
							}
						}
					}
				}
			}
		}
	}
end