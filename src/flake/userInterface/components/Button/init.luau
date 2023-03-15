--!strict
local SoundService = game:GetService("SoundService")

local root = script.Parent.Parent
local flake = root.Parent
local sounds = root.sounds
local libraries = flake.libraries

local Fusion = require(libraries.Fusion)
local ButtonThemes = require(script.themes)

local New, Ref, Value, Spring, OnEvent, Computed, Children = Fusion.New, Fusion.Ref, Fusion.Value, Fusion.Spring, Fusion.OnEvent, Fusion.Computed, Fusion.Children
export type ButtonProps = {
	Text: Fusion.CanBeState<string>?,
	Theme: string?,
	OnClick: () -> ()?,
	Disabled: boolean?,
	LayoutOrder: number?
}
return function(props: ButtonProps)
	local theme: any = ButtonThemes[props.Theme] or ButtonThemes.primary
	local disabled = props.Disabled
	
	local background = Value(0)
	local backgroundSpring = Spring(background, 1, 1)
	
	local border = Value(0)
	local borderSpring = Spring(border, 1, 1)
	
	local button = Value((nil :: any) :: TextButton)
	return New "TextButton" {
		LayoutOrder = props.LayoutOrder,
		Transparency = theme.noBackground and 1 or 0,
		AutomaticSize = Enum.AutomaticSize.XY,
		AutoButtonColor = false,
		BackgroundColor3 = Computed(function()
			return theme.background.normal:Lerp(theme.background.hover, background:get())
		end),
		[Ref] = button,
		[OnEvent "MouseButton1Down"] = function()
			if not disabled then
				local callback = props[OnEvent "MouseButton1Down"]
				if callback then
					task.defer(callback)
				end
				background:set(1)
			end
		end,
		[OnEvent "MouseButton1Up"] = function(x: number, y: number)
			if not disabled then
				local callback = props[OnEvent "MouseButton1Up"]
				if callback then
					task.defer(callback)
				end
				
				local button = button:get()
				local position, size, endPos = button.AbsolutePosition, button.AbsoluteSize, button.AbsolutePosition + button.AbsoluteSize
				local gui = button:FindFirstAncestorWhichIsA("ScreenGui")
				if gui and gui.IgnoreGuiInset then
					position += Vector2.new(0, 36)
					endPos += Vector2.new(0, 36)
				end

				if x > position.X and y > position.Y and x < endPos.X and y < endPos.Y then
					background:set(1)
					SoundService:PlayLocalSound(sounds.buttonPress)
					if props.OnClick then
						return props.OnClick()
					end
				else
					background:set(0)
				end
			end
		end :: any,
		[OnEvent "MouseEnter"] = function()
			if not disabled then
				local callback = props[OnEvent "MouseEnter"]
				if callback then
					task.defer(callback)
				end
				
				background:set(1)
				if theme.border then
					border:set(1)
				end
			end
		end,
		[OnEvent "MouseLeave"] = function()
			if not disabled then
				local callback = props[OnEvent "MouseEnter"]
				if callback then
					task.defer(callback)
				end

				background:set(0)
				if theme.border then
					border:set(0)
				end
			end
		end,
		[Children] = {
			New "UICorner" {
				CornerRadius = UDim.new(0, 4)
			},
			theme.border and New "UIStroke" {
				Color = Computed(function()
					return theme.border.normal:Lerp(theme.border.hover, border:get())
				end),
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			} or nil :: any,
			New "UIListLayout" {
				Padding = UDim.new(0, 8),
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Center
			},
			New "UIPadding" {
				PaddingTop = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 18),
				PaddingRight = UDim.new(0, 18),
				PaddingBottom = UDim.new(0, 8)
			},
			props[Children] or New "TextLabel" {
				Text = props.Text or "Button",
				TextSize = 14,
				RichText = true,
				FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Medium),
				TextColor3 = theme.color.normal,
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1
			}
		}
	}
end