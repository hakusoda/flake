--!strict
local root = script.Parent.Parent
local flake = root.Parent
local libraries = flake.libraries
local components = script.Parent

local t = require(flake.localisation)()
local theme = require(root.theme)()
local types = require(flake.types)
local llama = require(libraries.llama)
local Fusion = require(libraries.Fusion)
local Button = require(components.Button)
local Window = require(components.Window)

local New, Children = Fusion.New, Fusion.Children
export type PromptProps = {
	data: types.prompt,
	flake: types.flake
}
return function(props: PromptProps)
	local data = props.data
	local close = function()
		local list = props.flake.userInterface.prompts
		list:set(llama.List.removeValue(list:get(false), data))
	end
	return Window {
		icon = "rbxassetid://11260520498",
		title = data.title or "Unnamed Prompt",
		width = 350,
		height = 136,
		onClose = close,
		[Children] = {
			New "TextLabel" {
				Text = data.body,
				Size = UDim2.fromScale(1, 0),
				TextSize = 14,
				RichText = true,
				FontFace = theme.font400,
				Position = UDim2.fromOffset(0, 8),
				TextColor3 = theme.textPrimary,
				BackgroundTransparency = 1
			},
			New "Frame" {
				Size = UDim2.fromScale(1, 0),
				Position = UDim2.fromOffset(0, 40),
				Transparency = 1,
				[Children] = {
					New "UIListLayout" {
						Padding = UDim.new(0, 16),
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center
					},
					Button {
						Text = t("action.confirm"),
						OnClick = function()
							close()
							
							local callback = data.confirmButton
							if callback then
								callback()
							end
						end
					},
					data.cancelButton and Button {
						Text = t("action.cancel"),
						Theme = "secondary",
						OnClick = function()
							close()
							data.cancelButton()
						end,
						LayoutOrder = 1
					} :: any
				}
			}
		}
	}
end