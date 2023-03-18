--!strict
local root = script.Parent.Parent
local theme = require(root.theme)()
local Fusion = require(root.Parent.libraries.Fusion)
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
		FontFace = theme.font400,
		Position = props.Position,
		TextColor3 = theme.textPrimary,
		LayoutOrder = props.LayoutOrder,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		[Children] = New "UIPadding" {
			PaddingBottom = UDim.new(0, 8)
		}
	}
end