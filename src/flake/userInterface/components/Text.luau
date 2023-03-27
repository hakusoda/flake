--!strict
local root = script.Parent.Parent

local theme = require(root.theme)()
local Fusion = require(root.Parent.libraries.Fusion)

local New = Fusion.New
return function(text: Fusion.CanBeState<string>, size: number?, position: UDim2?, colour: Fusion.CanBeState<Color3>?, bold: boolean?)
	return New "TextLabel" {
		Text = text,
		Size = UDim2.fromOffset(size or 16, size or 16),
		RichText = true,
		TextSize = size,
		Position = position,
		FontFace = bold and theme.font500 or theme.font400,
		TextColor3 = colour or theme.textPrimary,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1
	}
end