--!strict
local root = script.Parent.Parent.Parent.Parent.Parent
local libraries = root.libraries
local userInterface = root.userInterface

local t = require(root.localisation)()
local util = require(root.util)
local types = require(root.types)
local llama = require(libraries.llama)
local theme = require(userInterface.theme)()
local Fusion = require(libraries.Fusion)
local Window = require(userInterface.components.Window)

local New, Value, Children, Computed = Fusion.New, Fusion.Value, Fusion.Children, Fusion.Computed
export type AddonProps = {
	addon: types.baseAddon,
	onClose: () -> ()
}
return function(props: AddonProps)
	local addon = props.addon
	local author = util.getAddonAuthor(addon.authors[1])
	return Window {
		title = t("addon-info"),
		width = 512,
		height = 284,
		visible = Value(true),
		onClose = props.onClose,
		[Children] = {
			New "UIListLayout" {
				Padding = UDim.new(0, 16),
				SortOrder = Enum.SortOrder.LayoutOrder
			},
			New "Frame" {
				Size = UDim2.new(1, 0, 0, 80),
				BackgroundColor3 = theme.backgroundSecondary,
				[Children] = {
					New "UICorner" { CornerRadius = UDim.new(0, 8) },
					New "UIPadding" {
						PaddingTop = UDim.new(0, 8),
						PaddingLeft = UDim.new(0, 8),
						PaddingRight = UDim.new(0, 8),
						PaddingBottom = UDim.new(0, 8)
					},
					New "ImageLabel" {
						Size = UDim2.fromOffset(64, 64),
						Image = util.getAddonIcon(addon.icon).main,
						Transparency = 1
					},
					New "TextLabel" {
						Size = UDim2.fromOffset(0, 16),
						Text = t("addon-info.name", {addon}),
						TextSize = 16,
						RichText = true,
						FontFace = theme.font500,
						Position = UDim2.fromOffset(80, 14),
						TextColor3 = theme.textPrimary,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundTransparency = 1
					},
					New "TextLabel" {
						Text = addon.description,
						Size = UDim2.fromOffset(0, 12),
						TextSize = 12,
						FontFace = theme.font400,
						Position = UDim2.fromOffset(80, 34),
						TextColor3 = theme.textSecondary,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundTransparency = 1
					}
				}
			},
			New "Frame" {
				Size = UDim2.new(1, 0, 0, 80),
				LayoutOrder = 1,
				BackgroundColor3 = theme.backgroundSecondary,
				[Children] = {
					New "UICorner" { CornerRadius = UDim.new(0, 8) },
					New "UIPadding" {
						PaddingTop = UDim.new(0, 8),
						PaddingLeft = UDim.new(0, 8),
						PaddingRight = UDim.new(0, 8),
						PaddingBottom = UDim.new(0, 8)
					},
					New "ImageLabel" {
						Size = UDim2.fromOffset(64, 64),
						Image = author.icon,
						Transparency = 1
					},
					New "TextLabel" {
						Size = UDim2.fromOffset(0, 16),
						Text = t("addon-info.author", {author}),
						TextSize = 16,
						RichText = true,
						FontFace = theme.font500,
						Position = UDim2.fromOffset(80, 14),
						TextColor3 = theme.textPrimary,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundTransparency = 1
					},
					#addon.authors > 1 and New "TextLabel" {
						Size = UDim2.fromOffset(0, 12),
						Text = t("addon-info.author2", {table.concat(llama.List.map(llama.List.shift(addon.authors), function(author)
							return util.getAddonAuthor(author).name
						end), ", ")}),
						TextSize = 12,
						FontFace = theme.font400,
						Position = UDim2.fromOffset(80, 34),
						TextColor3 = theme.textSecondary,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundTransparency = 1
					} or nil :: any
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
				TextColor3 = theme.textPrimary,
				LayoutOrder = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundColor3 = theme.backgroundSecondary,
				[Children] = New "UICorner" {}
			}
		}
	}
end