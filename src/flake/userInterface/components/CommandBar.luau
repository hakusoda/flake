--!strict
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local root = script.Parent.Parent
local flake = root.Parent
local libraries = flake.libraries
local components = script.Parent

local types = require(flake.types)
local Fusion = require(libraries.Fusion)
local Window = require(components.Window)
local InputLabel = require(components.InputLabel)
local flakeActions = require(flake.networking.data).actions

local New, Ref, Value, Cleanup, OnEvent, Computed, Children, OnChange = Fusion.New, Fusion.Ref, Fusion.Value, Fusion.Cleanup, Fusion.OnEvent, Fusion.Computed, Fusion.Children, Fusion.OnChange
export type CommandBarProps = {
	flake: types.flake
}
return function(props: CommandBarProps)
	local flake = props.flake
	local visible = flake.userInterface.commandBarVisible
	local touchEnabled = UserInputService.TouchEnabled

	local flash = Value(false)
	local textBox = Value(nil)
	local inputText = Value("")

	local lastTime = 0
	local flashConnection = RunService.PreSimulation:Connect(function()
		local time = os.clock()
		if time - lastTime >= 0.5 then
			lastTime = time
			local textBox = textBox:get()
			if textBox and visible:get() then
				textBox:CaptureFocus()
				if not touchEnabled then
					flash:set(not flash:get())
				else
					flash:set(false)
				end
			end
		end
	end)

	local matchText = Computed(function()
		return string.split(string.gsub(inputText:get(), "\t", ""), " ")[1]
	end)
	local aliasMatches = Computed(function()
		local matches = {}
		for _,command in flake.commands.commands:get() do
			for _,alias in command.aliases:get() do
				if string.find(alias, matchText:get()) == 1 then
					table.insert(matches, {command, alias :: any})
				end
			end
		end

		return matches
	end)
	local matchedCommand = Computed(function()
		return flake.commands:getByAlias(matchText:get())
	end)

	local match = Computed(function()
		return aliasMatches:get()[1]
	end)
	local text = Computed(function()
		local text = inputText:get()
		local match = match:get()
		local original = text
		local command = matchedCommand:get()
		if #text > 0 then
			local color = command and Color3.new(1, 1, 1) or Color3.fromRGB(226, 90, 93)
			if match then
				text = string.format("<font color=\"#%s\">%s</font><font color=\"#b4b4b4\">%s</font><br/><font transparency=\"1\">%s</font>%s", color:ToHex(), original, string.sub(match[2] :: any, #original + 1), original, flash and "_" or "")
			else
				text = string.format("<font color=\"#%s\">%s</font>", color:ToHex(), text)
			end
		else
			text = "commands"
		end
		local color = command and Color3.new(1, 1, 1) or Color3.fromRGB(226, 90, 93)
		if match then
			text = string.format("<font color=\"#%s\">%s</font><font color=\"#b4b4b4\">%s</font><br/><font transparency=\"1\">%s</font>", color:ToHex(), original, string.sub(match[2] :: any, #original + 1), original)
		end

		local textBox = textBox:get()
		if flash:get() and textBox then
			text ..= "<br/><font transparency=\"1\">"..string.sub(original, 1, textBox.CursorPosition).."</font>_"
		end
		return text
	end)
	local function close()
		local textBox = textBox:get()
		if textBox then
			textBox.Text = ""
		end
		inputText:set("")
		visible:set(false)
	end
	local function finish()
		local text = inputText:get()
		local alias = string.split(text, " ")[1]
		if #alias > 0 then
			local commands = flake.commands
			local command = commands:getByAlias(alias)
			if command then
				if command:hasPermission(flake.player) then
					local context = command.context:get()
					if context == "server" or context == "both" then
						flake.networking:sendAction(flakeActions.EXECUTE_COMMAND_STRING, {text})
					end
					if context == "client" or context == "both" then
						task.defer(commands.processCommandString, commands, flake.player, text)
					end
				else
					flake.userInterface:notify("Command error", "You do not have permission to run <b>"..alias.."</b>.")
				end
			else
				flake.userInterface:notify("Command error", "<b>"..alias.."</b> is not a valid command.")
			end
		end
		
		close()
	end

	return Window {
		title = "Command Bar",
		height = 150,
		onClose = close,
		visible = visible,
		[Children] = {
			InputLabel { "Type a command" },
			New "TextBox" {
				Size = UDim2.fromScale(1, 0),
				TextSize = 12,
				Position = UDim2.fromOffset(0, 24),
				FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
				AutomaticSize = Enum.AutomaticSize.Y,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTransparency = 1,
				ClearTextOnFocus = false,
				BackgroundColor3 = Color3.fromRGB(45, 45, 45),
				[Ref] = textBox,
				[Cleanup] = flashConnection,
				[Children] = {
					New "UICorner" {
						CornerRadius = UDim.new(0, 8)
					},
					New "UIPadding" {
						PaddingTop = UDim.new(0, 8),
						PaddingLeft = UDim.new(0, 12),
						PaddingRight = UDim.new(0, 12),
						PaddingBottom = UDim.new(0, 8)
					},
					New "TextLabel" {
						Text = text,
						TextSize = 12,
						RichText = true,
						FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
						LineHeight = 0,
						TextColor3 = #inputText == 0 and Color3.fromRGB(140, 140, 140) or Color3.fromRGB(240, 240, 240),
						AutomaticSize = Enum.AutomaticSize.XY,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundTransparency = 1
					}
				},
				[OnChange "Text"] = function(text: string)
					if string.find(text, "\t") then
						local matchText = string.gsub(text, "\t", "")
						local aliasMatches = {}
						for _,command in flake.commands.commands:get() do
							for _,alias in command.aliases:get() do
								if string.find(alias, matchText) == 1 then
									table.insert(aliasMatches, {command, alias :: any})
								end
							end
						end

						local alias = aliasMatches[1]
						if alias then
							text = alias[2] :: any
						else
							text = string.gsub(text, "\t", "")
						end
					end
					inputText:set(text)
				end,
				[OnEvent "FocusLost"] = function(enterPressed: boolean)
					if enterPressed then
						finish()
					end
				end
			},

			New "TextLabel" {
				Text = touchEnabled and "You may experience issues with typing on your device." or "Press TAB to use autocomplete (basic & prone to issues)",
				TextSize = 10,
				Position = UDim2.fromOffset(0, 76),
				FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
				TextColor3 = Color3.new(.6, .6, .6),
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1
			}
		}
	}
end