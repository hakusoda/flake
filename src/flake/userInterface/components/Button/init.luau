--!strict
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local root = script.Parent.Parent
local module = root.Parent
local sounds = root:WaitForChild("sounds")
local libraries = module:WaitForChild("libraries")

local vring = require(libraries:WaitForChild("vring"))
local Roact = require(libraries:WaitForChild("roact-compat"))
local ButtonThemes = require(script:WaitForChild("themes"))

local Button = Roact.Component:extend("Button")
function Button:init()
	local theme: any = ButtonThemes[self.props.theme] or ButtonThemes.primary

	self.background, self.updateBackground = Roact.createBinding(0)
	self.backgroundMotor = vring.linearMotor.new(self.background:getValue())
    :onStep(function(value)
		self.updateBackground(value)
	end)
    :connectStepper(RunService.Stepped)

	self.border, self.updateBorder = Roact.createBinding(0)
	self.borderMotor = vring.linearMotor.new(self.border:getValue())
	:onStep(function(value)
		self.updateBorder(value)
	end)
    :connectStepper(RunService.Stepped)

	self.color, self.updateColor = Roact.createBinding(0)
	self.colorMotor = vring.linearMotor.new(self.color:getValue())
	:onStep(function(value)
		self.updateColor(value)
	end)
    :connectStepper(RunService.Stepped)
end

function Button:render()
	local theme: any = ButtonThemes[self.props.theme] or ButtonThemes.primary
	return Roact.createElement("TextButton", {
		Text = "",
		TextSize = 12,
		AutomaticSize = Enum.AutomaticSize.XY,
		AutoButtonColor = false,
		BackgroundColor3 = self.background:map(function(value)
            return theme.background.normal:Lerp(theme.background.hover, value)
		end),
		BackgroundTransparency = theme.noBackground and 1 or 0,
		[Roact.Event.MouseButton1Down] = function()
			if not self.props.disabled then
				if self.props[Roact.Event.MouseButton1Down] then
					self.props[Roact.Event.MouseButton1Down]()
				end
                self.backgroundMotor:setTarget(1)
			end
		end,
		[Roact.Event.MouseButton1Up] = function(rbx: TextButton, x: number, y: number)
			if not self.props.disabled then
				if self.props[Roact.Event.MouseButton1Up] then
					self.props[Roact.Event.MouseButton1Up]()
				end

				local position, size, endPos = rbx.AbsolutePosition, rbx.AbsoluteSize, rbx.AbsolutePosition + rbx.AbsoluteSize
				local gui = rbx:FindFirstAncestorWhichIsA("ScreenGui")
				if gui and gui.IgnoreGuiInset then
					position += Vector2.new(0, 36)
					endPos += Vector2.new(0, 36)
				end

				if x > position.X and y > position.Y and x < endPos.X and y < endPos.Y then
					self.backgroundMotor:setTarget(1)
					SoundService:PlayLocalSound(sounds.buttonPress)
					if self.props.onClick then
						return self.props.onClick()
					end
				else
					self.backgroundMotor:setTarget(0)
				end
			end
		end :: any,
		[Roact.Event.MouseEnter] = function()
			if not self.props.disabled then
				if self.props[Roact.Event.MouseEnter] then
					self.props[Roact.Event.MouseEnter]()
				end
				--self.backgroundMotor:setTarget(theme.background.hover)
                self.backgroundMotor:setTarget(1)
				if theme.border then
					--self.borderMotor:setTarget(theme.border.hover)
                    self.borderMotor:setTarget(1)
				end
			end
		end,
		[Roact.Event.MouseLeave] = function()
			if not self.props.disabled then
				if self.props[Roact.Event.MouseLeave] then
					self.props[Roact.Event.MouseLeave]()
				end
				--self.backgroundMotor:setTarget(theme.background.normal)
                self.backgroundMotor:setTarget(0)
				if theme.border then
					--self.borderMotor:setTarget(theme.border.normal)
                    self.borderMotor:setTarget(0)
				end
			end
		end
	}, {
		Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 4)
		}),
		theme.border and Roact.createElement("UIStroke", {
			Color = self.border:map(function(value)
                return theme.border.normal:Lerp(theme.border.hover, value)
            end),
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}) or nil,
		Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 8),
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center
		}),
		Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingBottom = UDim.new(0, 4)
		}),
		self.props[Roact.Children] and
			table.unpack(self.props[Roact.Children]) or
			Roact.createElement("TextLabel", {
				Text = self.props.text or "Button",
				TextSize = 12,
				RichText = true,
				FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Medium),
				TextColor3 = self.color:map(function(value)
                    return theme.color.normal:Lerp(Color3.new(), value)
				end),
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1
			})
	})
end

return Button