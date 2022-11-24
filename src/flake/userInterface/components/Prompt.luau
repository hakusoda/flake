--!strict
local root = script.Parent.Parent.Parent
local actions = script.Parent.Parent:WaitForChild("actions")
local libraries = root:WaitForChild("libraries")
local components = script.Parent

local Roact = require(libraries:WaitForChild("roact-compat"))
local Button = require(components:WaitForChild("Button"))
local Window = require(components:WaitForChild("Window"))
local EndPrompt = require(actions:WaitForChild("EndPrompt"))
local RoactRodux = require(libraries:WaitForChild("roact-rodux"))

local createElement = Roact.createElement
return RoactRodux.connect(nil, function(dispatch)
	return {
		onClose = function(id)
			dispatch(EndPrompt(id))
		end
	}
end)(function(props)
    local data, setData = Roact.useState({ options = {} })
    Roact.useEffect(function()
        if props.data then
            setData(props.data)
        end
    end, {props.data})

    local promptData = props.data or data
	return createElement(Window, {
        icon = "rbxassetid://11260520498",
        title = "prompt",
        width = 350,
        height = 128,
        hidden = not props.data,
        onClose = function()
            props.onClose(promptData.id)
        end
    }, {
        createElement("UIListLayout", {
            Padding = UDim.new(0, 16)
        }),
        createElement("TextLabel", {
            Text = promptData.options.body,
            Size = UDim2.fromScale(1, 0),
            TextSize = 14,
            RichText = true,
            FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
            TextColor3 = Color3.new(1, 1, 1),
            AutomaticSize = Enum.AutomaticSize.Y,
            TextXAlignment = Enum.TextXAlignment.Center,
            BackgroundTransparency = 1
        }),
        createElement("Frame", {
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1
        }, {
            createElement("UIListLayout", {
                Padding = UDim.new(0, 16),
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
            promptData.options.confirmButton and createElement(Button, {
                text = "Confirm",
                onClick = function()
                    props.onClose(promptData.id)
                    promptData.options.confirmButton()
                end
            }),
            promptData.options.cancelButton and createElement(Button, {
                text = "Cancel",
                theme = "secondary",
                onClick = function()
                    props.onClose(promptData.id)
                    promptData.options.cancelButton()
                end
            })
        })
    })
end)