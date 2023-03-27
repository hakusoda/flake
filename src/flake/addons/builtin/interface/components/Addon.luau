--!strict
local root = script.Parent.Parent.Parent.Parent.Parent
local libraries = root.libraries
local userInterface = root.userInterface
local components = userInterface.components

local t = require(root.localisation)()
local util = require(root.util)
local Icon = require(components.Icon)
local Text = require(components.Text)
local types = require(root.types)
local llama = require(libraries.llama)
local theme = require(userInterface.theme)()
local Fusion = require(libraries.Fusion)
local Window = require(components.Window)

local New, Value, Children, Computed = Fusion.New, Fusion.Value, Fusion.Children, Fusion.Computed
export type AddonProps = {
	addon: types.baseAddon,
	onClose: () -> ()
}
return function(props: AddonProps)
	local addon = props.addon
	local author = util.getAddonAuthor(addon.authors[1])
	local otherAuthors = table.concat(llama.List.map(llama.List.shift(addon.authors), function(author)
		return util.getAddonAuthor(author).name
	end), ", ")
	return Window {
		title = t("addon-info"),
		width = 512,
		height = 284,
		visible = Value(true),
		onClose = props.onClose,
		[Children] = {
			New "Frame" {
				Size = UDim2.new(1, 0, 0, 80),
				BackgroundColor3 = theme.backgroundSecondary,
				[Children] = {
					New "UICorner" {},
					Icon(addon:getIcon("main"), 64, 8, 8, true),
					Text(t("addon-info.name", {addon}), 16, UDim2.fromOffset(88, 22), nil, true),
					Text(addon.description, 12, UDim2.fromOffset(88, 42), theme.textSecondary)
				}
			},
			New "Frame" {
				Size = UDim2.new(1, 0, 0, 80),
				Position = UDim2.fromOffset(0, 96),
				BackgroundColor3 = theme.backgroundSecondary,
				[Children] = {
					New "UICorner" {},
					Icon(author.icon, 64, 8, 8, true),
					Text(t("addon-info.author", {author}), 16, UDim2.fromOffset(88, 22), nil, true),
					#addon.authors > 1 and
						Text(t("addon-info.author2", {otherAuthors}), 12, UDim2.fromOffset(88, 42), theme.textSecondary) or nil :: any
				}
			},
			New "TextLabel" {
				Size = UDim2.new(1, 0, 0, 28),
				Text = Computed(function()
					return t("addon-info.extra", {addon.id, (#addon.commands:get()) :: any}):get()
				end),
				TextSize = 12,
				RichText = true,
				FontFace = theme.font400,
				Position = UDim2.fromOffset(0, 192),
				TextColor3 = theme.textPrimary,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundColor3 = theme.backgroundSecondary,
				[Children] = New "UICorner" {}
			}
		}
	}
end