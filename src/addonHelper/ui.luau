--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = ReplicatedStorage:WaitForChild("flakeModule"):WaitForChild("userInterface"):WaitForChild("components")

local Text = require(components:WaitForChild("Text"))
local Icon = require(components:WaitForChild("Icon"))
local Fusion = require(script.Parent.Fusion.PubTypes)
local Window = require(components:WaitForChild("Window"))

local ui = {}
function ui.text(text: Fusion.CanBeState<string>, size: number?, position: UDim2?, colour: Fusion.CanBeState<Color3>?, bold: boolean?)
	return Text(text, size, position, colour, bold)
end

function ui.icon(image: Fusion.CanBeState<string>, size: number, posX: number?, posY: number?, removeBackground: boolean?)
	return Icon(image, size, posX, posY, removeBackground)
end

function ui.window(props: {
	title: string,
	width: number?,
	height: number?,
	onClose: () -> ()?,
	visible: Fusion.StateObject<boolean>?,
	position: UDim2?
})
	return Window(props)
end

return ui