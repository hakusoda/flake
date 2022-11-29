--!strict
local Stats = game:GetService("Stats")
local Terrain = workspace.Terrain
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GameSettings = UserSettings():GetService("UserGameSettings")
local ContentProvider = game:GetService("ContentProvider")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local root = script.Parent.Parent
local flake = (ReplicatedStorage :: any).flakeModule
local player = Players.LocalPlayer
local actions = root.store.actions
local libraries = flake.libraries
local userInterface = flake.userInterface
local flakeComponents = userInterface.components

local store = require(root.store)
local llama = require(libraries.llama)
local Roact = require(libraries["roact-compat"])
local Window = require(flakeComponents.Window)
local RoactRodux = require(libraries["roact-rodux"])
local InputLabel = require(flakeComponents.InputLabel)
local FormatNumber = require(root.FormatNumber.Simple)
local SetClientInfoVisible = require(actions.SetClientInfoVisible)

local formatNumber = FormatNumber.Format
local useMemo, useState, useEffect, createElement, createFragment = Roact.useMemo, Roact.useState, Roact.useEffect, Roact.createElement, Roact.createFragment

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
local information = {
	{"General", {
		{"FPS", "number", function()
			local fps, setFps = useState({0, 0})
			local stepper = useMemo(function()
				local frames = 0
				local elapsed = 0
				local elapsed2 = 0
				return RunService.Heartbeat:Connect(function(deltaTime)
                    frames += 1
                    elapsed += deltaTime
                    elapsed2 += deltaTime

                    if elapsed > 1 then
                        table.insert(frameAverage, frames)

                        local average = 0
                        for _,i in pairs(frameAverage) do
                            average += i
                        end
        
                        setFps({frames, math.round(average / #frameAverage)})
                        frames = 0
                        elapsed = 0
                    end
                    if elapsed2 > 5 then
                        frameAverage = {}
                    end
                end)
            end, {})
            useEffect(function()
                return function()
                    frameAverage = {}
                    stepper:Disconnect()
                end
            end, {})

            return fps[1], formatNumber(fps[1]).." ("..formatNumber(fps[2]).." average)"
        end},
        {"Ping", "ms", function()
            return player:GetNetworkPing()
        end},
        {"Instances", "number", function()
            local count = Stats.InstanceCount
            return count, count.." ("..formatNumber(count - #game:GetDescendants()).." nil)"
        end},
        {"Session Time", "ms", function()
            return time() * 1000
        end},
        {"Memory Usage", "kb", function()
            return Stats:GetTotalMemoryUsageMb() * 1000
        end},
    }}, {"Network", {
        {"Data Send", "kbps", function()
            return Stats.DataSendKbps
        end},
        {"Data Receive", "kbps", function()
            return Stats.DataReceiveKbps
        end},
        {"Physics Send", "kbps", function()
            return Stats.PhysicsSendKbps
        end},
        {"Physics Receive", "kbps", function()
            return Stats.PhysicsReceiveKbps
        end}
    }}, {"Physics", {
        {"Primitives", "number", function()
            return Stats.PrimitivesCount
        end},
        {"Moving Primitives", "number", function()
            return Stats.MovingPrimitivesCount
        end}
    }}, {"Rendering", {
        {"Quality Level", "string", function()
            return GameSettings.SavedQualityLevel.Name
        end}
    }}, {"Input", {
        {"Touch Available", "boolean", function()
            return UserInputService.TouchEnabled
        end},
        {"Gamepad Available", "boolean", function()
            return UserInputService.GamepadEnabled
        end},
        {"Keyboard Available", "boolean", function()
            return UserInputService.KeyboardEnabled
        end},
        {"Gyroscope Available", "boolean", function()
            return UserInputService.GyroscopeEnabled
        end},
        {"Accelerometer Available", "boolean", function()
            return UserInputService.AccelerometerEnabled
        end},
    }, false}, {"Miscellaneous", {
        {"Terrain Cells", "number", function()
            return Terrain:CountCells()
        end},
        {"Streaming Enabled", "boolean", function()
            return workspace.StreamingEnabled
        end},
        {"Content Request Queue", "number", function()
            local size = ContentProvider.RequestQueueSize
            return size, size.." Pending"
        end}
    }}, {"Categorized Memory Usage", llama.List.map(Enum.DeveloperMemoryTag:GetEnumItems(), function(item)
        return {item.Name, "kb", function()
            return math.floor(Stats:GetMemoryUsageMbForTag(item) * 1000)
        end}
    end), false}
}

function InfoItem(props)
    local item = props.item
    local value, text = item[3]()
    return createElement("TextLabel", {
        Text = string.format("%s: <b>%s</b>", item[1], text or useValue(value, item[2])),
        Size = UDim2.fromScale(1, 0),
        TextSize = 12,
        RichText = true,
        FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
        TextColor3 = Color3.new(.9, .9, .9),
        LayoutOrder = props.index,
        AutomaticSize = Enum.AutomaticSize.Y,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    }, {
        createElement("UICorner"),
        createElement("UIPadding", {
            PaddingTop = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 6)
        })
    })
end

function InfoCategory(props)
    local key = props.index
    local data = props.data
    local show, setShow = useState(if typeof(data[3]) == "boolean" then data[3] else true)
    return createFragment({
        createElement("Frame", {
            Size = UDim2.fromScale(1, 0),
            LayoutOrder = key - 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1
        }, {
            createElement(InputLabel, {}, data[1]),
            createElement("ImageButton", {
                Size = UDim2.fromOffset(16, 16),
                Image = "rbxassetid://11699907635",
                Rotation = show and 0 or -90,
                Position = UDim2.new(1, -4, 0, 0),
                AnchorPoint = Vector2.new(1, 0),
                ImageColor3 = Color3.new(.9, .9, .9),
                BackgroundTransparency = 1,
                [Roact.Event.Activated] = function()
                    setShow(function(value)
                        return not value
                    end)
                end
            })
        }),
        createElement("Frame", {
            Size = UDim2.fromScale(1, 0),
            LayoutOrder = key,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1
        }, {
            createElement("UIPadding", {
                PaddingBottom = UDim.new(0, 8)
            }),
            createElement("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            show and createFragment(llama.List.map(data[2], function(item, key)
                return createElement(InfoItem, { item = item, index = key })
            end))
        })
    })
end

local ClientInfo = RoactRodux.connect(function(state)
	return { visible = state.interface.clientInfoVisible }
end, function(dispatch)
	return { onClose = function()
        dispatch(SetClientInfoVisible(false))
    end }
end)(function(props)
    if not props.visible then
        return
    end

    return createElement(Window, {
        icon = "rbxassetid://11568224787",
        title = "Client Information",
        height = 258,
        hidden = not props.visible,
        onClose = props.onClose
    }, {
        createElement("ScrollingFrame", {
            Size = UDim2.new(1, 0, 0, 196),
            CanvasSize = UDim2.fromScale(0, 0),
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1
        }, {
            createElement("UIPadding", {
                PaddingRight = UDim.new(0, 8)
            }),
            createElement("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            createFragment(llama.List.map(information, function(cat, key)
                return createElement(InfoCategory, { data = cat, index = key })
            end))
        })
    })
end)

return function(props)
    return createElement(RoactRodux.StoreProvider, {
		store = store
	}, {
        createElement(ClientInfo, props)
    })
end