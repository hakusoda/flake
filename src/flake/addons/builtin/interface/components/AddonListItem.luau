--!strict
local root = script.Parent.Parent
local flake = root.Parent.Parent.Parent
local libraries = flake.libraries
local userInterface = flake.userInterface
local components = userInterface.components

local Icon = require(components.Icon)
local Text = require(components.Text)
local types = require(flake.types)
local theme = require(userInterface.theme)()
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
			Icon(addon:getIcon("list"), 40, 8, 8),
			Text(Computed(function()
				return `{addon.name or addon.id} <font size=\"8\" color=\"#{(theme.textSecondary :: any):get():ToHex()}\">v{addon.version}</font>`
			end), 13, UDim2.fromOffset(56, 16), nil, true),
			Text(addon.description, 10, UDim2.fromOffset(56, 30), theme.textSecondary)
		}
	}
end