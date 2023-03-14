--!strict
local root = script.Parent.Parent
local flake = root.Parent.Parent.Parent
local libraries = flake.libraries

local util = require(flake.util)
local types = require(flake.types)
local Fusion = require(libraries.Fusion)
local interface = require(root.types)

local New, OnEvent, Children = Fusion.New, Fusion.OnEvent, Fusion.Children
export type AddonListItemProps = {
	addon: types.baseAddon,
	interface: interface.interfaceAddon
}
return function(props: AddonListItemProps)
	local addon = props.addon
	return New "TextButton" {
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = Color3.fromRGB(45, 45, 45),
		[OnEvent "Activated"] = function()
			props.interface.viewAddon:set(addon)
		end,
		[Children] = {
			New "UICorner" {},
			New "UIPadding" {
				PaddingTop = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 8)
			},
			New "Frame" {
				Transparency = 1,
				AutomaticSize = Enum.AutomaticSize.XY,
				[Children] = {
					New "ImageLabel" {
						Size = UDim2.fromOffset(40, 40),
						Image = util.getAddonIcon(addon.icon).list,
						Transparency = 1,
						[Children] = New "UICorner" {
							CornerRadius = UDim.new(0, 4)
						}
					},
					New "Frame" {
						Size = UDim2.fromOffset(0, 40),
						Position = UDim2.fromOffset(48, 0),
						Transparency = 1,
						[Children] = {
							New "UIListLayout" {
								Padding = UDim.new(0, 1),
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Center
							},
							New "TextLabel" {
								Text = `{addon.name or addon.id} <font size=\"8\" color=\"#c8c8c8\">v{addon.version or "0.0.0"} by {util.authorsToString(addon.authors)}</font>{string.find(addon.id, "builtin") == 1 and "   <font size=\"8\" color=\"#c8c8c8\"><sc>(BUILT-IN ADDON)</sc></font>" or ""}`,
								TextSize = 12,
								RichText = true,
								FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Medium),
								TextColor3 = Color3.new(.8, .8, .8),
								AutomaticSize = Enum.AutomaticSize.XY,
								BackgroundTransparency = 1
							},
							addon.description and New "TextLabel" {
								Text = addon.description,
								TextSize = 10,
								FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
								TextColor3 = Color3.new(.6, .6, .6),
								LayoutOrder = 1,
								AutomaticSize = Enum.AutomaticSize.XY,
								BackgroundTransparency = 1
							} or nil :: any
						}
					}
				}
			}
		}
	}
end