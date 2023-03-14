--!strict
local SoundService = game:GetService("SoundService")

local root = script.Parent.Parent
local flake = root.Parent
local sounds = root.sounds
local libraries = flake.libraries

local types = require(flake.types)
local images = require(root.images)
local Fusion = require(libraries.Fusion)

local New, Value, Spring, OnEvent, Computed, Children, ForPairs = Fusion.New, Fusion.Value, Fusion.Spring, Fusion.OnEvent, Fusion.Computed, Fusion.Children, Fusion.ForPairs
export type TouchMenuProps = {
	flake: types.flake
}
return function(props: TouchMenuProps)
	local flake = props.flake
	
	local alpha = Value(0)
	local alphaSpring = Spring(alpha, 8)
	return Computed(function()
		if not flake.userInterface.touchMenuVisible:get() then
			return nil :: any
		end
		return New "ImageLabel" {
			Size = UDim2.fromOffset(400, 48),
			Image = images.TOUCH_MENU_BG,
			Position = UDim2.fromScale(0.5, 0),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(48, 0, 168, 48),
			ImageColor3 = Color3.fromRGB(60, 60, 60),
			AnchorPoint = Computed(function()
				return Vector2.new(0.5, 1 - alphaSpring:get())
			end),
			Transparency = 1,
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
							ForPairs(props.flake.userInterface.touchMenuItems, function(key, item)
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
					SliceCenter = Rect.new(48, 16, 168, 16),
					ImageColor3 = Color3.fromRGB(60, 60, 60),
					Transparency = 1,
					[Children] = New "TextLabel" {
						Text = "flake menu",
						Size = UDim2.fromScale(1, 1),
						TextSize = 14,
						FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Medium),
						TextColor3 = Color3.fromRGB(240, 240, 240),
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