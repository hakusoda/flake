--!strict
local Roact = require(script.Parent.Parent.Parent.libraries["roact-compat"])
return function(props)
	return Roact.createElement("TextLabel", {
		Text = props.children,
		TextSize = 12,
		FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
		TextColor3 = Color3.fromRGB(240, 240, 240),
        LayoutOrder = props.LayoutOrder,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1
	}, {
		Roact.createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 4)
		})
	})
end