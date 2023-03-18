--!strict
local root = script.Parent.Parent
local flake = root.Parent.Parent.Parent
local libraries = flake.libraries
local components = script.Parent
local userInterface = flake.userInterface

local t = require(flake.localisation)()
local types = require(flake.types)
local theme = require(userInterface.theme)()
local Fusion = require(libraries.Fusion)
local images = require(userInterface.images)
local Window = require(userInterface.components.Window)
local interface = require(root.types)
local AddonListItem = require(components.AddonListItem)

local New, Computed, Children, ForValues = Fusion.New, Fusion.Computed, Fusion.Children, Fusion.ForValues
export type FlakeInfoProps = {
	flake: types.flake,
	addon: interface.interfaceAddon
}
return function(props: FlakeInfoProps)
	local flake = props.flake
	local addons = flake.addons.loaded
	local interface = props.addon

	local visible = interface.flakeInfoVisible
	return Window {
		title = t("flake-info"),
		width = 512,
		height = 298,
		onClose = function()
			visible:set(false)
		end,
		visible = Computed(function()
			return visible:get() and not interface.viewAddon:get()
		end),
		[Children] = {
			New "UIListLayout" { Padding = UDim.new(0, 16) },
			New "Frame" {
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = theme.backgroundSecondary,
				[Children] = {
					New "UICorner" {},
					New "UIPadding" {
						PaddingTop = UDim.new(0, 8),
						PaddingLeft = UDim.new(0, 8),
						PaddingRight = UDim.new(0, 8),
						PaddingBottom = UDim.new(0, 8)
					},
					New "ImageLabel" {
						Size = UDim2.fromOffset(64, 64),
						Image = images.FLAKE_ICON,
						Transparency = 1
					},
					New "Frame" {
						Size = UDim2.fromOffset(0, 64),
						Position = UDim2.fromOffset(80, 0),
						Transparency = 1,
						[Children] = {
							New "UIListLayout" {
								Padding = UDim.new(0, 4),
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Center
							},
							New "TextLabel" {
								Text = t("flake-info.name", {flake}),
								TextSize = 16,
								RichText = true,
								FontFace = theme.font500,
								TextColor3 = theme.textPrimary,
								AutomaticSize = Enum.AutomaticSize.XY,
								BackgroundTransparency = 1
							},
							New "TextLabel" {
								Text = t("flake-info.summary"),
								TextSize = 12,
								FontFace = theme.font400,
								TextColor3 = theme.textSecondary,
								LayoutOrder = 1,
								AutomaticSize = Enum.AutomaticSize.XY,
								BackgroundTransparency = 1
							}
						}
					}
				}
			},
			New "Frame" {
				Size = UDim2.fromScale(1, 0),
				Transparency = 1,
				[Children] = {
					New "TextLabel" {
						Text = Computed(function()
							return t("flake-info.addons", {#addons:get()}):get()
						end),
						TextSize = 12,
						FontFace = theme.font400,
						TextColor3 = theme.textPrimary,
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1
					},
					New "ScrollingFrame" {
						Size = UDim2.new(1, 0, 0, 120),
						Position = UDim2.fromOffset(0, 18),
						CanvasSize = UDim2.fromScale(1, 1),
						Transparency = 1,
						ScrollBarThickness = 4,
						ScrollingDirection = Enum.ScrollingDirection.Y,
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						ScrollBarImageColor3 = Color3.new(1, 1, 1),
						[Children] = {
							New "UIListLayout" {
								Padding = UDim.new(0, 8)
							},
							ForValues(addons, function(addon: types.baseAddon)
								return AddonListItem {
									addon = addon,
									interface = interface
								}
							end, Fusion.cleanup) :: any
						}
					}
				}
			}
		}
	}
end