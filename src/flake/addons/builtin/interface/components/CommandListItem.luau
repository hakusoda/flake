--!strict
local root = script.Parent.Parent.Parent.Parent.Parent
local libraries = root.libraries

local types = require(root.types)
local theme = require(root.userInterface.theme)()
local Fusion = require(libraries.Fusion)

local New, Children, Computed = Fusion.New, Fusion.Children, Fusion.Computed
export type CommandListItemProps = {
	key: number,
	command: types.command
}
return function(props: CommandListItemProps)
	local command = props.command
	return New "TextLabel" {
		Size = UDim2.new(1, 0, 0, 24),
		Text = Computed(function()
			local aliases = command.aliases:get()
			return string.format("%s%s(%s)", aliases[1] or "", aliases[2] and (", "..aliases[2].." ") or " ", command.id)
		end),
		TextSize = 12,
		FontFace = theme.font400,
		TextColor3 = theme.textPrimary,
		LayoutOrder = props.key,
		AutomaticSize = Enum.AutomaticSize.Y,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundColor3 = theme.backgroundSecondary,
		[Children] = {
			New "UICorner" {},
			New "UIPadding" {
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8)
			}
		}
	}
end