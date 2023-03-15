--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = ReplicatedStorage:WaitForChild("flakeModule"):WaitForChild("userInterface"):WaitForChild("components")

local Fusion = require(script.Parent.Fusion.PubTypes)
local Window = require(components:WaitForChild("Window"))
local InputLabel = require(components:WaitForChild("InputLabel"))

local ui = {}
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

function ui.inputLabel(props: {
	[number]: string,
	Position: UDim2?,
	LayoutOrder: number?
})
	return InputLabel(props)
end

return ui