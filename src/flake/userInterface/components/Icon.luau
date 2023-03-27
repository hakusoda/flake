--!strict
local root = script.Parent.Parent

local theme = require(root.theme)()
local Fusion = require(root.Parent.libraries.Fusion)

local New, Children = Fusion.New, Fusion.Children
return function(image: Fusion.CanBeState<string>, size: number, posX: number?, posY: number?, removeBackground: boolean?)
	return New "ImageLabel" {
		Size = UDim2.fromOffset(size, size),
		Image = image,
		Position = UDim2.fromOffset(posX or 0, posY or 0),
		Transparency = removeBackground and 1 or 0,
		BackgroundColor3 = theme.backgroundPrimary,
		[Children] = New "UICorner" {
			CornerRadius = UDim.new(0, 4)
		}
	}
end