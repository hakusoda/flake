--!strict
local Stats = game:GetService("Stats")
local Terrain = workspace.Terrain
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GameSettings = UserSettings():GetService("UserGameSettings")
local ContentProvider = game:GetService("ContentProvider")
local UserInputService = game:GetService("UserInputService")

local root = script.Parent.Parent
local player = Players.LocalPlayer
local libraries = root.libraries
local addonHelper = root.addonHelper

local ui = require(addonHelper.ui)
local types = require(root.types)
local llama = require(libraries.llama)
local Fusion = require(root.addonHelper.Fusion)
local flakeTypes = require(addonHelper.types)
local FormatNumber = require(root.FormatNumber.Simple)

local formatNumber = FormatNumber.Format
local New, Value, OnEvent, Cleanup, Children, Computed = Fusion.New, Fusion.Value, Fusion.OnEvent, Fusion.Cleanup, Fusion.Children, Fusion.Computed

local decimalMult = 10 ^ 2
function formatMs(value: number)
	if value >= 86400000 then
		return formatNumber(math.modf((value / 86400000) * decimalMult) / decimalMult).." Days"
	elseif value >= 3600000 then
		return formatNumber(math.modf((value / 3600000) * decimalMult) / decimalMult).." Hours"
	elseif value >= 60000 then
		return formatNumber(math.modf((value / 60000) * decimalMult) / decimalMult).." Minutes"
	elseif value >= 1000 then
		return formatNumber(math.modf((value / 1000) * decimalMult) / decimalMult).." Seconds"
	end
	return formatNumber(math.round(value)).." Milliseconds"
end

function formatKb(value: number)
	if value >= 1000000 then
		return formatNumber(math.modf((value / 1000000) * decimalMult) / decimalMult).." GB"
	elseif value >= 1000 then
		return formatNumber(math.modf((value / 1000) * decimalMult) / decimalMult).." MB"
	end
	return formatNumber(math.modf(value * decimalMult) / decimalMult).." KB"
end

function useValue(value: any, type: string)
	if type == "number" then
		return formatNumber(value)
	elseif type == "ms" then
		return formatMs(value)
	elseif type == "kb" then
		return formatKb(value)
	elseif type == "kbps" then
		return formatKb(value).."/s"
	elseif type == "boolean" then
		return value and "Yes" or "No"
	end
	return value
end

local frameAverage = {}
local information: {{any}} = {
	{"General", {
		{"FPS", "number", function()
			local fps = Value({0, 0})
			
			local frames = 0
			local elapsed = 0
			local elapsed2 = 0
			local stepper = RunService.PreSimulation:Connect(function(deltaTime)
				frames += 1
				elapsed += deltaTime
				elapsed2 += deltaTime

				if elapsed > 1 then
					table.insert(frameAverage, frames)

					local average = 0
					for _,i in frameAverage do
						average += i
					end

					fps:set({frames, math.round(average / #frameAverage)})
					frames = 0
					elapsed = 0
				end
				if elapsed2 > 5 then
					frameAverage = {}
				end
			end)
			
			return Computed(function()
				local fps = fps:get()
				return {fps[1], formatNumber(fps[1]).." ("..formatNumber(fps[2]).." average)" :: any}
			end), stepper
		end :: any},
		{"Ping", "ms", function()
			return {player:GetNetworkPing()}
		end :: any},
		{"Instances", "number", function()
			local count = Stats.InstanceCount
			return {count, count.." ("..formatNumber(count - #game:GetDescendants()).." nil)"}
		end :: any},
		{"Session Time", "ms", function()
			return {time() * 1000}
		end :: any},
		{"Memory Usage", "kb", function()
			return {Stats:GetTotalMemoryUsageMb() * 1000}
		end :: any},
	}}, {"Network", {
		{"Data Send", "kbps", function()
			return {Stats.DataSendKbps}
		end :: any},
		{"Data Receive", "kbps", function()
			return {Stats.DataReceiveKbps}
		end :: any},
		{"Physics Send", "kbps", function()
			return {Stats.PhysicsSendKbps}
		end :: any},
		{"Physics Receive", "kbps", function()
			return {Stats.PhysicsReceiveKbps}
		end :: any}
	}}, {"Physics", {
		{"Primitives", "number", function()
			return {Stats.PrimitivesCount}
		end :: any},
		{"Moving Primitives", "number", function()
			return {Stats.MovingPrimitivesCount}
		end :: any}
	}}, {"Rendering", {
		{"Quality Level", "string", function()
			return {GameSettings.SavedQualityLevel.Name}
		end :: any}
	}}, {"Input", {
		{"Touch Available", "boolean", function()
			return {UserInputService.TouchEnabled}
		end :: any},
		{"Gamepad Available", "boolean", function()
			return {UserInputService.GamepadEnabled}
		end :: any},
		{"Keyboard Available", "boolean", function()
			return {UserInputService.KeyboardEnabled}
		end :: any},
		{"Gyroscope Available", "boolean", function()
			return {UserInputService.GyroscopeEnabled}
		end :: any},
		{"Accelerometer Available", "boolean", function()
			return {UserInputService.AccelerometerEnabled}
		end :: any},
	}, false}, {"Miscellaneous", {
		{"Terrain Cells", "number", function()
			return {Terrain:CountCells()}
		end :: any},
		{"Streaming Enabled", "boolean", function()
			return {workspace.StreamingEnabled}
		end :: any},
		{"Content Request Queue", "number", function()
			local size = ContentProvider.RequestQueueSize
			return {size, size.." Pending"}
		end :: any}
	}}, {"Categorized Memory Usage", llama.List.map(Enum.DeveloperMemoryTag:GetEnumItems(), function(item)
		return {item.Name, "kb", function()
			return {math.floor(Stats:GetMemoryUsageMbForTag(item) * 1000)}
		end}
	end), false}
}

export type InfoItemProps = {
	key: number,
	item: {any}
}
function InfoItem(props: InfoItemProps)
	local item = props.item
	local values, cleanup = item[3]()
	return New "TextLabel" {
		Text = Computed(function()
			local values = values
			if typeof(values) == "table" and values.get then
				values = values:get()
			end
			
			return string.format("%s: <b>%s</b>", item[1], values[2] or useValue(values[1], item[2]))
		end),
		Size = UDim2.fromScale(1, 0),
		TextSize = 12,
		RichText = true,
		FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
		TextColor3 = Color3.new(.9, .9, .9),
		LayoutOrder = props.key,
		AutomaticSize = Enum.AutomaticSize.Y,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundColor3 = Color3.fromRGB(45, 45, 45),
		[Cleanup] = cleanup,
		[Children] = {
			New "UICorner" {},
			New "UIPadding" {
				PaddingTop = UDim.new(0, 6),
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 6)
			}
		}
	}
end

export type InfoCategoryProps = {
	key: number,
	data: {string}
}
function InfoCategory(props: InfoCategoryProps)
	local key = props.key
	local data = props.data
	local show = Value(if typeof(data[3]) == "boolean" then data[3] else true)
	return {
		New "Frame" {
			Size = UDim2.fromScale(1, 0),
			LayoutOrder = key - 1,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			[Children] = {
				ui.inputLabel { data[1] },
				New "ImageButton" {
					Size = UDim2.fromOffset(16, 16),
					Image = "rbxassetid://11699907635",
					Rotation = show and 0 or -90,
					Position = UDim2.new(1, -4, 0, 0),
					AnchorPoint = Vector2.new(1, 0),
					ImageColor3 = Color3.new(.9, .9, .9),
					BackgroundTransparency = 1,
					[OnEvent "Activated"] = function()
						show:set(not show:get())
					end
				}
			}
		},
		New "Frame" {
			Size = UDim2.fromScale(1, 0),
			LayoutOrder = key,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			[Children] = {
				New "UIPadding" {
					PaddingBottom = UDim.new(0, 8)
				},
				New "UIListLayout" {
					Padding = UDim.new(0, 8),
					SortOrder = Enum.SortOrder.LayoutOrder
				},
				Computed(function()
					if not show:get() then
						return nil :: any
					end
					return llama.List.map(data[2], function(item, key)
						return InfoItem { key = key, item = item }
					end)
				end) :: any
			}
		}
	}
end

export type ClientInfoProps = {
	flake: flakeTypes.flake,
	addon: types.essentialsAddon
}
return function(props: ClientInfoProps)
	return ui.window {
		icon = "rbxassetid://11568224787",
		title = "Client Information",
		height = 258,
		visible = props.addon.clientInfoVisible,
		[Children] = New "ScrollingFrame" {
			Size = UDim2.new(1, 0, 0, 196),
			Transparency = 1,
			ScrollBarThickness = 4,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarImageColor3 = Color3.new(1, 1, 1),
			[Children] = {
				New "UIPadding" {
					PaddingRight = UDim.new(0, 8)
				},
				New "UIListLayout" {
					SortOrder = Enum.SortOrder.LayoutOrder
				},
				llama.List.map(information, function(cat, key)
					return InfoCategory { key = key, data = cat }
				end)
			}
		}
	}
end