--!strict
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local root = script.Parent.Parent
local flake = root.Parent
local actions = flake.store.actions
local libraries = flake.libraries
local components = script.Parent

local types = require(flake.types)
local Roact = require(libraries["roact-compat"])
local Window = require(components.Window)
local RoactRodux = require(libraries["roact-rodux"])
local InputLabel = require(components.InputLabel)
local flakeContext = require(components.flakeContext)
local flakeActions = require(flake.networking.data).actions
local SetCommandBarVisible = require(actions.SetCommandBarVisible)

--TODO: rewrite as a functional component
type CommandBar = {
	state: any,
	props: { [string]: any },
	setState: any,

	cursorFlash: any, setCursorFlash: (boolean) -> (),
	textBox: any,
	flashcon: RBXScriptConnection,

	finish: (self: CommandBar, flake: types.flake) -> (),
	capture: (self: CommandBar) -> ()
}

local CommandBar = Roact.PureComponent:extend("CommandBar")
function CommandBar:init()
	self:setState({
		text = ""
	})

	local lastTime = 0
	self.flashcon = RunService.Stepped:Connect(function(time: number)
		if time - lastTime >= 0.5 then
			lastTime = time
			if not UserInputService.TouchEnabled and self.textBox.current and self.textBox.current:IsFocused() then
				self.setCursorFlash(not self.cursorFlash:getValue())
			else
				self.setCursorFlash(false)
			end
		end
	end)
	self.cursorFlash, self.setCursorFlash = Roact.createBinding(false)
	self.textBox = Roact.createRef()
end

function CommandBar:render()
	local text: string = self.state.text

	local aliasMatches = {}
	local matchedCommand
	local matchText = string.split(string.gsub(text, "\t", ""), " ")[1]
	for _,command: types.command in pairs(self.props.commands) do
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
	local touchEnabled = UserInputService.TouchEnabled

	return Roact.createElement(flakeContext.Consumer, {
		render = function(flake: types.flake)
			return Roact.createElement(Window, {
				icon = "rbxassetid://11568224787",
				title = "Command bar",
				height = 128,
				hidden = not self.props.commandBarVisible,
				anchor = touchEnabled and Vector2.new(0.5, 0) or nil,
				onClose = function()
					self:setState({ text = "" })
					self.props.onClose()
				end,
				changed = function()
                    task.delay(0.1, self.capture, self)
				end,
				position = touchEnabled and UDim2.fromScale(0.5, 0.1) or nil
			}, {
				Roact.createElement("UIListLayout"),
				Roact.createElement(InputLabel, nil, "Type a command"),
				Roact.createElement("TextBox", {
					Text = self.state.text,
					Size = UDim2.fromOffset(200, 0),
					TextSize = 12,
					FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
					AutomaticSize = Enum.AutomaticSize.XY,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTransparency = 1,
					ClearTextOnFocus = false,
					BackgroundColor3 = Color3.fromRGB(60, 60, 60),
					[Roact.Ref] = self.textBox,
					[Roact.Change.Text] = function(rbx: TextBox)
						if self.state.text ~= rbx.Text then
							self:setState({ text = rbx.Text })
						end
					end,
					[Roact.Event.FocusLost] = function(rbx: TextBox, enterPressed: boolean)
						if enterPressed then
							self:finish(flake)
						end
					end,
					[Roact.Change.CursorPosition] = function()
						self:setState({})
					end
				}, {
					Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0, 4)
					}),
					Roact.createElement("UIPadding", {
						PaddingTop = UDim.new(0, 8),
						PaddingLeft = UDim.new(0, 12),
						PaddingRight = UDim.new(0, 12),
						PaddingBottom = UDim.new(0, 8)
					}),
					Roact.createElement("TextLabel", {
						Text = self.cursorFlash:map(function(flash: boolean)
							local boxText = text
							if #text > 0 then
								local color = matchedCommand and Color3.new(1, 1, 1) or Color3.fromRGB(226, 90, 93)
								if match then
									boxText = string.format("<font color=\"#%s\">%s</font><font color=\"#b4b4b4\">%s</font><br/><font transparency=\"1\">%s</font>%s", color:ToHex(), text, string.sub(match[2] :: any, #text + 1), text, flash and "_" or "")
								else
									boxText = string.format("<font color=\"#%s\">%s</font>", color:ToHex(), text)
								end
							else
								boxText = "cmds"
							end
							local color = matchedCommand and Color3.new(1, 1, 1) or Color3.fromRGB(226, 90, 93)
							if match then
								boxText = string.format("<font color=\"#%s\">%s</font><font color=\"#b4b4b4\">%s</font><br/><font transparency=\"1\">%s</font>%s", color:ToHex(), text, string.sub(match[2] :: any, #text + 1), text, flash and "_" or "")
							end
                            local textBox = self.textBox.current
							if flash and textBox then
								boxText ..= "<br/><font transparency=\"1\">"..string.sub(text, 1, textBox.CursorPosition).."</font>_"
							end
							return boxText
						end),
						TextSize = 12,
						RichText = true,
						FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
						LineHeight = 0,
						TextColor3 = #text == 0 and Color3.fromRGB(180, 180, 180) or Color3.fromRGB(240, 240, 240),
						AutomaticSize = Enum.AutomaticSize.XY,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundTransparency = 1
					})
				}),

				Roact.createElement("TextLabel", {
					Text = UserInputService.TouchEnabled and "You may experience issues with typing on your device." or "Press TAB to use autocomplete (basic & prone to issues)",
					TextSize = 10,
					FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
					TextColor3 = Color3.fromRGB(180, 180, 180),
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundTransparency = 1
				}, {
					Roact.createElement("UIPadding", {
						PaddingTop = UDim.new(0, 16)
					})
				})
			})
		end
	})
end

function CommandBar:finish(flake: types.flake)
	local text = self.state.text
	local alias = string.split(text, " ")[1]
	local command = flake.commands:getByAlias(alias)
	if command then
		if command:hasPermission(flake.player) then
            local context = command.context
			if context == "server" or context == "both" then
				flake.networking:sendAction(flakeActions.EXECUTE_COMMAND_STRING, {
					text
				})
            end
			if context == "client" or context == "both" then
				task.defer(function()
					flake.commands:processCommandString(flake.player, text)
				end)
			end
		else
			flake.userInterface:notify("Command error", "You do not have permission to run <b>"..alias.."</b>.")
		end
	else
		flake.userInterface:notify("Command error", "<b>"..alias.."</b> is not a valid command.")
	end
	self.props.onClose()
	self:setState({ text = "" })
end

function CommandBar:capture()
	local textBox: TextBox? = self.textBox.current
	if textBox and not textBox:IsFocused() then
		textBox:CaptureFocus()
	end
end

function CommandBar:didUpdate()
	if not UserInputService.TouchEnabled then
		local text = self.state.text
		if string.find(text, "\t") then
			local matchText = string.gsub(text, "\t", "")
			local aliasMatches = {}
			for _,command: types.command in pairs(self.props.commands) do
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
			self:setState({ text = text })
		end
	end
end

function CommandBar:willUnmount()
	self.flashcon:Disconnect()
	self.flashcon = nil :: any
end

return RoactRodux.connect(function(state)
	return {
		commands = state.commandBar.commands,
		commandBarVisible = state.commandBar.visible
	}
end, function(dispatch)
	return { onClose = function()
        dispatch(SetCommandBarVisible(false))
    end }
end)(CommandBar)