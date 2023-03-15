--!strict
local root = script.Parent.Parent.Parent.Parent.Parent
local libraries = root.libraries
local userInterface = root.userInterface

local util = require(root.util)
local types = require(root.types)
local llama = require(libraries.llama)
local Fusion = require(libraries.Fusion)
local images = require(userInterface.images)
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
		title = "Addon Information",
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
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Color3.fromRGB(45, 45, 45),
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
					New "Frame" {
						Size = UDim2.fromOffset(0, 64),
						Position = UDim2.fromOffset(80, 0),
						Transparency = 1,
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
			},
			New "Frame" {
				Size = UDim2.fromScale(1, 0),
				LayoutOrder = 1,
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Color3.fromRGB(45, 45, 45),
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
					New "Frame" {
						Size = UDim2.fromOffset(0, 64),
						Position = UDim2.fromOffset(80, 0),
						Transparency = 1,
						[Children] = {
							New "UIListLayout" {
								Padding = UDim.new(0, 4),
								VerticalAlignment = Enum.VerticalAlignment.Center
							},
							New "TextLabel" {
								Text = `Created by <b>{author.name}</b>`,
								TextSize = 16,
								RichText = true,
								FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Medium),
								TextColor3 = Color3.new(.8, .8, .8),
								AutomaticSize = Enum.AutomaticSize.XY,
								BackgroundTransparency = 1
							},
							#addon.authors > 1 and New "TextLabel" {
								Text = `...and {table.concat(llama.List.map(llama.List.shift(addon.authors), function(author)
									return util.getAddonAuthor(author).name
								end), ", ")}`,
								TextSize = 12,
								FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
								TextColor3 = Color3.new(.6, .6, .6),
								AutomaticSize = Enum.AutomaticSize.XY,
								BackgroundTransparency = 1
							} or nil :: any
						}
					}
				}
			},
			New "TextLabel" {
				Size = UDim2.new(1, 0, 0, 28),
				Text = Computed(function()
					return `    <b>ID:</b>  {addon.id}        <b>Commands:</b>  {#addon.commands:get()}`
				end),
				TextSize = 12,
				RichText = true,
				FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
				TextColor3 = Color3.new(.8, .8, .8),
				LayoutOrder = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundColor3 = Color3.fromRGB(45, 45, 45),
				[Children] = {
					New "UICorner" {}
				}
			}
		}
	}
end