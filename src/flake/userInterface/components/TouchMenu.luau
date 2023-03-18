--!strict
local SoundService = game:GetService("SoundService")

local root = script.Parent.Parent
local flake = root.Parent
local sounds = root.sounds
local libraries = flake.libraries

local t = require(flake.localisation)()
local theme = require(root.theme)()
local types = require(flake.types)
local images = require(root.images)
local Fusion = require(libraries.Fusion)

local New, Value, Spring, OnEvent, Computed, Children, ForPairs = Fusion.New, Fusion.Value, Fusion.Spring, Fusion.OnEvent, Fusion.Computed, Fusion.Children, Fusion.ForPairs
export type TouchMenuProps = {
	flake: types.flake
}
return function(props: TouchMenuProps)
	local interface = props.flake.userInterface
	
	local alpha = Value(0)
	local alphaSpring = Spring(alpha, 16)
	return Computed(function()
		if not interface.touchMenuVisible:get() then
			return nil :: any
		end
		return New "ImageLabel" {
			Size = UDim2.fromOffset(400, 48),
			Image = images.TOUCH_MENU_BG,
			Position = UDim2.new(0.5, 0, 0, -interface.gui.AbsolutePosition.Y - 36),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(48, 0, 168, 48),
			ImageColor3 = theme.backgroundSecondary,
			AnchorPoint = Computed(function()
				return Vector2.new(0.5, 1 - alphaSpring:get())
			end),
			Transparency = 1,
			ImageTransparency = Computed(function()
				return (alpha:get() == 1 or alphaSpring:get() > 0.01) and 0 or 1
			end),
			[Children] = {
				Computed(function()
					if alpha:get() == 0 then
						return nil :: any
					end
					return New "Frame" {
						Size = UDim2.fromScale(1, 1),
						Transparency = 1,
						[Children] = {
							New "UIListLayout" {
								Padding = UDim.new(0, 16),
								SortOrder = Enum.SortOrder.LayoutOrder,
								FillDirection = Enum.FillDirection.Horizontal,
								VerticalAlignment = Enum.VerticalAlignment.Center,
								HorizontalAlignment = Enum.HorizontalAlignment.Center
							},
							ForPairs(interface.touchMenuItems, function(key, item)
								return key, New "ImageButton" {
									Size = UDim2.fromOffset(40, 40),
									Image = item.icon,
									LayoutOrder = key,
									BackgroundTransparency = 1,
									[OnEvent "Activated"] = function()
										SoundService:PlayLocalSound(sounds.buttonPress)

										alpha:set(0)
										item.onClick()
									end
								}
							end, Fusion.cleanup) :: any
						}
					}
				end, Fusion.cleanup) :: any,
				New "ImageButton" {
					Size = UDim2.fromOffset(140, 24),
					Image = images.TOUCH_MENU_BG,
					Position = UDim2.fromScale(0.5, 1),
					ScaleType = Enum.ScaleType.Slice,
					LayoutOrder = 1,
					AnchorPoint = Vector2.new(0.5, 0),
					SliceCenter = Rect.new(96, 24, 336, 24),
					ImageColor3 = theme.backgroundSecondary,
					Transparency = 1,
					[Children] = New "TextLabel" {
						Text = t("touch-menu"),
						Size = UDim2.fromScale(1, 1),
						TextSize = 14,
						FontFace = theme.font500,
						TextColor3 = theme.textPrimary,
						BackgroundTransparency = 1
					},
					[OnEvent "Activated"] = function()
						SoundService:PlayLocalSound(sounds.buttonPress)
						alpha:set(alpha:get() == 0 and 1 or 0)
					end
				}
			}
		}
	end, Fusion.cleanup)
end