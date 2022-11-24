--!strict
local root = script.Parent.Parent
local module = root.Parent
local libraries = module.libraries

local Roact = require(libraries["roact-compat"])
return function(props)
	return Roact.createElement("TextLabel", {
		Text = props[Roact.Children],
		TextSize = 12,
		FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
		TextColor3 = Color3.fromRGB(240, 240, 240),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1
	}, {
		Roact.createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 4)
		})
	})
end