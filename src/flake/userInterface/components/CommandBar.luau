--!strict
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")

local root = script.Parent.Parent
local flake = root.Parent
local libraries = flake.libraries
local components = script.Parent

local t = require(flake.localisation)()
local Text = require(components.Text)
local theme = require(root.theme)()
local types = require(flake.types)
local llama = require(libraries.llama)
local Fusion = require(libraries.Fusion)
local Window = require(components.Window)
local flakeActions = require(flake.networking.data).actions

local New, Ref, Value, Cleanup, OnEvent, Computed, Children, OnChange, ForPairs, Observer = Fusion.New, Fusion.Ref, Fusion.Value, Fusion.Cleanup, Fusion.OnEvent, Fusion.Computed, Fusion.Children, Fusion.OnChange, Fusion.ForPairs, Fusion.Observer
export type CommandBarProps = {
	flake: types.flake
}
return function(props: CommandBarProps)
	local flake = props.flake
	local visible = flake.userInterface.commandBarVisible
	local commands = flake.commands
	local touchEnabled = UserInputService.TouchEnabled

	local flash = Value(false)
	local textBox = Value(nil :: TextBox?)
	local inputText = Value("")

	local lastTime = 0
	local flashConnection = RunService.PreSimulation:Connect(function()
		local time = os.clock()
		if time - lastTime >= 0.5 then
			lastTime = time
			local textBox = textBox:get(false)
			if textBox and visible:get(false) then
				textBox:CaptureFocus()
				if not touchEnabled then
					flash:set(not flash:get(false))
				else
					flash:set(false)
				end
			end
		end
	end)
	
	local text = Value("")
	local tabbing = Value(false)
	local argument = Value(nil :: types.commandArgument?)
	local cursorPos = Value(0)
	local cmdMatches = Value({} :: {types.commandSuggestion})
	local currentCmd = Value(nil :: types.command?)
	local selectedMatch = Value(-1)
	local argSuggestions = Value({} :: {types.commandArgumentSuggestion})
	local invalidArguments = Value({})
	local function refresh(input: string, pos: number)
		local command = currentCmd:get(false)
		local cursorPos = cursorPos:get(false)
		local suggestions = argSuggestions:get(false)
		local invalidArgs = invalidArguments:get(false)
		if not tabbing:get(false) then
			if command then
				local aliasText = string.split(input, " ")[1]
				if #input > #aliasText then
					local argStart = #aliasText + 2
					local newSuggestions, invalid = command:getSuggestions(string.sub(input, argStart), cursorPos - argStart + 1)
					invalidArgs = invalid
					suggestions = newSuggestions
				end
			else
				invalidArgs = {}
				suggestions = {}
			end
			argSuggestions:set(suggestions)
			invalidArguments:set(invalidArgs)
		end
		
		local selected = selectedMatch:get(false)
		local cmdSuggestions = cmdMatches:get(false)
		if command then
			local full = {}
			local arguments = command.arguments:get(false)
			argument:set(arguments[math.min(#string.split(string.sub(input, 1, pos + 1), " ") - 1, #arguments)])
			
			for key, text in string.split(input, " ") do
				local original = text
				local argument = arguments[math.min(key - 1, #arguments)]
				if argument then
					local type: types.commandArgumentType = argument.type
					local color = invalidArgs[argument.id] and "ff0000" or (type == "players" or argument.suggestor) and "54ffff" or "ffff00"
					text = `<font color="#{color}">{text}</font>`

					local suggestion = suggestions[selected]
					if suggestion and suggestion.argument == argument then
						text = `{text}<font transparency="0.5">{string.sub(suggestion.text, #original + 1)}</font>`
					end
				end
				table.insert(full, text)
			end
			return text:set(table.concat(full, " "))
		end

		local match = cmdSuggestions[selected]
		if match then
			return text:set(`{input}<font transparency="0.5">{string.sub(match.text, #input + 1)}</font>`)
		end

		text:set(input)
	end
	Observer(inputText):onChange(function()
		local input = inputText:get(false)
		if input == "" then
			cmdMatches:set({})
			return currentCmd:set(nil)
		end
		
		local command, suggestions = commands:getCommand(string.split(input, " ")[1])
		if currentCmd:get(false) ~= command then
			currentCmd:set(command)
		end
		cmdMatches:set(suggestions)
	end)
	
	local function close()
		local textBox = textBox:get(false)
		if textBox then
			textBox.Text = ""
		end
		visible:set(false)
		tabbing:set(false)
		inputText:set("")
		selectedMatch:set(-1)
	end
	local function finish()
		local text = inputText:get(false)
		local alias = string.split(text, " ")[1]
		if #alias > 0 then
			local commands = flake.commands
			local command = commands:getByAlias(alias)
			if command then
				if command:hasPermission(flake.player) then
					local context = command.context:get(false)
					if context == "server" or context == "both" then
						flake.networking:sendAction(flakeActions.EXECUTE_COMMAND_STRING, {text})
					end
					if context == "client" or context == "both" then
						task.defer(commands.processCommandString, commands, flake.player, text)
					end
				else
					flake.userInterface:notify(t("error.command"), t("error.no-permission", {alias}))
				end
			else
				flake.userInterface:notify(t("error.command"), t("error.invalid-command", {alias}))
			end
		end
		
		close()
	end
	local input = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		local newSelected = -1
		if input.KeyCode == Enum.KeyCode.Up then
			local length = math.max(#cmdMatches:get(false), #argSuggestions:get(false))
			newSelected = (selectedMatch:get(false) - 2) % length + 1
		elseif input.KeyCode == Enum.KeyCode.Down then
			local length = math.max(#cmdMatches:get(false), #argSuggestions:get(false))
			newSelected = selectedMatch:get(false) % length + 1
		end
		
		if newSelected ~= -1 then
			selectedMatch:set(newSelected)
		end
	end)
	
	local boundsParams = Instance.new("GetTextBoundsParams")
	boundsParams.Size = 12
	boundsParams.Font = Font.fromName("GothamSSm")
	
	local fakeCursorPos = Computed(function()
		local pos = cursorPos:get()
		local text = inputText:get()
		boundsParams.Text = string.sub(text, 1, pos - 1)
		
		local bounds = TextService:GetTextBoundsAsync(boundsParams)
		return UDim2.fromOffset(13 + bounds.X, 8)
	end)
	
	local function getSuggestion(key: number): types.commandArgumentSuggestion?
		for _,item in argSuggestions:get(false) do
			if item.index == key then
				return item
			end
		end
		return
	end
	
	return Window {
		title = t("command-bar"),
		height = 150,
		onClose = close,
		visible = visible,
		[Children] = {
			Text(t("command-bar.type")),
			New "TextBox" {
				Size = UDim2.new(1, 0, 0, 28),
				TextSize = 12,
				FontFace = theme.font400,
				Position = UDim2.fromOffset(0, 24),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTransparency = 1,
				ClearTextOnFocus = false,
				BackgroundColor3 = theme.backgroundSecondary,
				[Ref] = textBox,
				[Cleanup] = flashConnection,
				[Children] = {
					New "UICorner" {},
					New "Frame" {
						Size = UDim2.fromOffset(1, 12),
						Visible = flash,
						Position = fakeCursorPos,
						BackgroundColor3 = theme.textPrimary
					},
					New "TextLabel" {
						Text = text,
						Size = UDim2.fromScale(1, 1),
						TextSize = 12,
						RichText = true,
						FontFace = theme.font400,
						Position = UDim2.fromOffset(12, 0),
						LineHeight = 0,
						TextColor3 = theme.textPrimary,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundTransparency = 1
					},
					ForPairs(Computed(function()
						local key = selectedMatch:get()
						local matches = cmdMatches:get()
						local suggestions = argSuggestions:get()
						if key > -1 then
							local items = (#suggestions > 0 and suggestions or matches) :: { text: string, index: number }
							if #items > 4 then
								return llama.List.reverse(llama.List.slice(items, math.max(key - 3, 1), math.max(key - 3, 1) + 3))
							end
							return llama.List.reverse(items)
						end
						return {}
					end), function(key, item)
						return key, New "TextLabel" {
							Text = item.text,
							Size = UDim2.fromOffset(0, 18),
							TextSize = 14,
							FontFace = theme.font400,
							Position = UDim2.fromOffset(0, -22 - 18 * (key - 1)),
							TextColor3 = Computed(function()
								return selectedMatch:get() == item.index and Color3.new(1, 1, 0) or (theme.textPrimary :: any):get()
							end),
							AutomaticSize = Enum.AutomaticSize.X,
							BackgroundColor3 = theme.backgroundSecondary,
							[Children] = {
								New "UICorner" { CornerRadius = UDim.new(0, 2) },
								New "UIPadding" {
									PaddingLeft = UDim.new(0, 4),
									PaddingRight = UDim.new(0, 4)
								}
							}
						}
					end, Fusion.cleanup) :: any,
					Computed(function()
						local argument = argument:get()
						if argument and #cmdMatches:get() == 0 and #argSuggestions:get() == 0 then
							local invalid = invalidArguments:get()[argument.id]
							return New "TextLabel" {
								Size = UDim2.fromOffset(0, 18),
								Text = invalid or `<{argument.id}>`,
								TextSize = 14,
								FontFace = theme.font400,
								Position = UDim2.fromOffset(0, -22),
								TextColor3 = invalid and Color3.new(1, 0, 0) or theme.textSecondary,
								AutomaticSize = Enum.AutomaticSize.X,
								BackgroundColor3 = theme.backgroundSecondary,
								[Children] = {
									New "UICorner" { CornerRadius = UDim.new(0, 2) },
									New "UIPadding" {
										PaddingLeft = UDim.new(0, 4),
										PaddingRight = UDim.new(0, 4)
									}
								}
							}
						end
						return nil :: any
					end, Fusion.cleanup) :: any
				},
				[OnChange "Text"] = function(text: string)
					if text == inputText:get(false) then
						return
					end
					
					local textBox = textBox:get(false)
					local originalText = text
					if text == "" then
						tabbing:set(false)
						selectedMatch:set(-1)
					elseif string.find(text, "\t") then
						text = string.gsub(text, "\t", "")
						local matches = cmdMatches:get(false)
						local suggestions = argSuggestions:get(false)
						if #matches > 0 or #suggestions > 0 then
							local key = selectedMatch:get(false)
							if key == -1 or not tabbing:get(false) then
								key = 1
							else
								key = key % math.max(#matches, #suggestions) + 1
							end
							tabbing:set(true)
							selectedMatch:set(key)
							
							local suggestion = getSuggestion(key)
							if suggestion then
								local split = string.split(text, " ")
								for key, text in split do
									if key - 1 == suggestion.argumentIndex then
										split[key] = suggestion.text
									end
								end
								text = table.concat(split, " ")
							else
								local match = matches[key]
								if match then
									text = match.text
								end
							end
							inputText:set(text)
						end
						
						refresh(text, #text + 1)
						if text ~= originalText and textBox then
							textBox.Text = text
							textBox.CursorPosition = #text + 1
						end
						return
					else
						tabbing:set(false)
						selectedMatch:set(string.sub(text, #text) == " " and 0 or 1)
					end
					
					if text ~= inputText:get(false) then
						refresh(text, cursorPos:get(false))
						inputText:set(text)
					end
				end,
				[OnEvent "FocusLost"] = function(enterPressed: boolean)
					if enterPressed then
						finish()
					elseif touchEnabled then
						close()
					end
				end,
				[OnChange "CursorPosition"] = function(value: number)
					if cursorPos:get(false) ~= value then
						cursorPos:set(value == -1 and #inputText:get(false) or value)
					end
				end
			},
			
			Text(t(`command-bar.info.{touchEnabled}`), 10, UDim2.fromOffset(0, 76), theme.textSecondary)
		}
	}
end