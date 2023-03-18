--!strict
local root = script.Parent.Parent
local flake = root.Parent.Parent.Parent
local libraries = flake.libraries

local util = require(flake.util)
local types = require(flake.types)
local theme = require(flake.userInterface.theme)()
local Fusion = require(libraries.Fusion)
local interface = require(root.types)

local New, OnEvent, Children, Computed = Fusion.New, Fusion.OnEvent, Fusion.Children, Fusion.Computed
export type AddonListItemProps = {
	addon: types.baseAddon,
	interface: interface.interfaceAddon
}
return function(props: AddonListItemProps)
	local addon = props.addon
	return New "TextButton" {
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = theme.backgroundSecondary,
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
			New "ImageLabel" {
				Size = UDim2.fromOffset(40, 40),
				Image = util.getAddonIcon(addon.icon).list,
				Transparency = 1,
				[Children] = New "UICorner" {
					CornerRadius = UDim.new(0, 4)
				}
			},
			New "TextLabel" {
				Size = UDim2.fromOffset(0, 13),
				Text = Computed(function()
					return `{addon.name or addon.id} <font size=\"8\" color=\"#{(theme.textSecondary :: any):get():ToHex()}\">v{addon.version}</font>`
				end),
				TextSize = 13,
				RichText = true,
				FontFace = theme.font500,
				Position = UDim2.fromOffset(48, 7),
				TextColor3 = theme.textPrimary,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1
			},
			addon.description and New "TextLabel" {
				Text = addon.description,
				Size = UDim2.fromOffset(0, 12),
				TextSize = 10,
				FontFace = theme.font400,
				Position = UDim2.fromOffset(48, 21),
				TextColor3 = theme.textSecondary,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1
			} or nil :: any
		}
	}
end