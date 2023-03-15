--!strict
local Fusion = require(script.Parent.Parent.Parent.libraries.Fusion)
local New, Children = Fusion.New, Fusion.Children

export type InputLabelProps = {
	[number]: Fusion.CanBeState<string>,
	
	Position: UDim2?,
	LayoutOrder: number?
}
return function(props: InputLabelProps)
	return New "TextLabel" {
		Text = props[1],
		TextSize = 14,
		Position = props.Position,
		FontFace = Font.fromName("GothamSSm"),
		TextColor3 = Color3.fromRGB(240, 240, 240),
		LayoutOrder = props.LayoutOrder,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		[Children] = New "UIPadding" {
			PaddingBottom = UDim.new(0, 8)
		}
	}
end