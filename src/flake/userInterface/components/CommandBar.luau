--!strict
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local root = script.Parent.Parent
local flake = root.Parent
local actions = flake.store.actions
local libraries = flake.libraries
local components = script.Parent

local types = require(flake.types)
local llama = require(libraries.llama)
local Roact = require(libraries["roact-compat"])
local Window = require(components.Window)
local RoactRodux = require(libraries["roact-rodux"])
local InputLabel = require(components.InputLabel)
local flakeContext = require(components.flakeContext)
local flakeActions = require(flake.networking.data).actions
local SetCommandBarVisible = require(actions.SetCommandBarVisible)

local useRef, useMemo, useState, useEffect, createElement = Roact.useRef, Roact.useMemo, Roact.useState, Roact.useEffect, Roact.createElement
function CommandBar(props)
    local flake = props.flake
    local touchEnabled = UserInputService.TouchEnabled

    local flash, setFlash = useState(false)
    local inputText, setInputText = useState("")
    local textBoxRef = useRef(nil)
    local flashConnection: RBXScriptConnection = useMemo(function()
        local lastTime = 0
        return RunService.Heartbeat:Connect(function()
            local time = os.clock()
            if time - lastTime >= 0.5 then
                lastTime = time
                local textBox = textBoxRef.current
                if not touchEnabled and textBox and textBox:IsFocused() then
                    setFlash(function(value)
                        return not value
                    end)
                else
                    setFlash(false)
                end
            end
        end)
    end, {})
    useEffect(function()
        return function()
            flashConnection:Disconnect()
        end
    end, {})

    local aliasMatches = {}
	local matchedCommand
	local matchText = string.split(string.gsub(inputText, "\t", ""), " ")[1]
	for _,command: types.command in pairs(flake.commands.commands) do
		for _,alias in pairs(command.aliases) do
			if string.find(alias, matchText) == 1 then
				table.insert(aliasMatches, {command, alias})
			end
			if matchText == alias then
				matchedCommand = command
			end
		end
	end

	local match = aliasMatches[1]
    local text = useMemo(function()
        local text = inputText
        if #text > 0 then
            local color = matchedCommand and Color3.new(1, 1, 1) or Color3.fromRGB(226, 90, 93)
            if match then
                text = string.format("<font color=\"#%s\">%s</font><font color=\"#b4b4b4\">%s</font><br/><font transparency=\"1\">%s</font>%s", color:ToHex(), inputText, string.sub(match[2] :: any, #inputText + 1), inputText, flash and "_" or "")
            else
                text = string.format("<font color=\"#%s\">%s</font>", color:ToHex(), text)
            end
        else
            text = "cmds"
        end
        local color = matchedCommand and Color3.new(1, 1, 1) or Color3.fromRGB(226, 90, 93)
        if match then
            text = string.format("<font color=\"#%s\">%s</font><font color=\"#b4b4b4\">%s</font><br/><font transparency=\"1\">%s</font>", color:ToHex(), inputText, string.sub(match[2] :: any, #inputText + 1), inputText)
        end

        local textBox = textBoxRef.current
        if flash and textBox then
            text ..= "<br/><font transparency=\"1\">"..string.sub(inputText, 1, textBox.CursorPosition).."</font>_"
        end
        return text
    end, {flash, inputText})
    local function finish()
        local alias = string.split(inputText, " ")[1]
        local commands = flake.commands
        local command = commands:getByAlias(alias)
        if command then
            if command:hasPermission(flake.player) then
                local context = command.context
                if context == "server" or context == "both" then
                    flake.networking:sendAction(flakeActions.EXECUTE_COMMAND_STRING, {inputText})
                end
                if context == "client" or context == "both" then
                    task.defer(commands.processCommandString, commands, flake.player, inputText)
                end
            else
                flake.userInterface:notify("Command error", "You do not have permission to run <b>"..alias.."</b>.")
            end
        else
            flake.userInterface:notify("Command error", "<b>"..alias.."</b> is not a valid command.")
        end
        props.onClose()
        setInputText("")

        local textBox = textBoxRef.current
        if textBox then
            textBox.Text = ""
        end
    end
    
    return createElement(Window, {
        icon = "rbxassetid://11568224787",
        title = "Command Bar",
        height = 150,
        hidden = not props.visible,
        --anchor = touchEnabled and Vector2.new(0.5, 0) or nil,
        onClose = function()
            setInputText("")
            props.onClose()

            local textBox = textBoxRef.current
            if textBox then
                textBox.Text = ""
            end
        end,
        changed = function()
            local textBox = textBoxRef.current
            if textBox then
                textBox:CaptureFocus()
            end
        end,
        --position = touchEnabled and UDim2.fromScale(0.5, 0.1) or nil
    }, {
        createElement("UIListLayout"),
        createElement(InputLabel, nil, "Type a command"),
        createElement("TextBox", {
            ref = textBoxRef,
            Text = "",
            Size = UDim2.fromScale(1, 0),
            TextSize = 12,
            FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
            AutomaticSize = Enum.AutomaticSize.Y,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 1,
            ClearTextOnFocus = false,
            BackgroundColor3 = Color3.fromRGB(45, 45, 45),
            [Roact.Change.Text] = function(rbx: TextBox)
                local text = rbx.Text
                if string.find(text, "\t") then
                    local matchText = string.gsub(text, "\t", "")
                    local aliasMatches = {}
                    for _,command: types.command in pairs(flake.commands.commands) do
                        for _,alias in pairs(command.aliases) do
                            if string.find(alias, matchText) == 1 then
                                table.insert(aliasMatches, {command, alias})
                            end
                        end
                    end
        
                    local alias = aliasMatches[1]
                    if alias then
                        text = alias[2] :: any
                    else
                        text = string.gsub(text, "\t", "")
                    end

                    --setting the CursorPosition doesn't work???
                    rbx.CursorPosition = string.len(text)
                end
                setInputText(text)
            end,
            [Roact.Event.FocusLost] = function(rbx: TextBox, enterPressed: boolean)
                if enterPressed then
                    finish()
                end
            end
        }, {
            createElement("UICorner", {
                CornerRadius = UDim.new(0, 8)
            }),
            createElement("UIPadding", {
                PaddingTop = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 8)
            }),
            createElement("TextLabel", {
                Text = text,
                TextSize = 12,
                RichText = true,
                FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
                LineHeight = 0,
                TextColor3 = #inputText == 0 and Color3.fromRGB(140, 140, 140) or Color3.fromRGB(240, 240, 240),
                AutomaticSize = Enum.AutomaticSize.XY,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1
            })
        }),

        createElement("TextLabel", {
            Text = touchEnabled and "You may experience issues with typing on your device." or "Press TAB to use autocomplete (basic & prone to issues)",
            TextSize = 10,
            FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
            TextColor3 = Color3.new(.6, .6, .6),
            AutomaticSize = Enum.AutomaticSize.XY,
            BackgroundTransparency = 1
        }, {
            createElement("UIPadding", {
                PaddingTop = UDim.new(0, 24)
            })
        })
    })
end

return RoactRodux.connect(function(state)
	return { visible = state.interface.commandBarVisible }
end, function(dispatch)
	return { onClose = function()
        dispatch(SetCommandBarVisible(false))
    end }
end)(function(props)
    return Roact.createElement(flakeContext.Consumer, {
		render = function(flake: types.flake)
			return Roact.createElement(CommandBar, llama.Dictionary.join({ flake = flake }, props))
		end
	})
end)