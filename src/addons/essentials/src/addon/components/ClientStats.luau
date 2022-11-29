--!strict
local Stats = game:GetService("Stats")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local root = script.Parent.Parent
local flake = (ReplicatedStorage :: any).flakeModule
local actions = root.store.actions
local libraries = flake.libraries
local userInterface = flake.userInterface
local flakeComponents = userInterface.components

local llama = require(libraries.llama)
local Roact = require(libraries["roact-compat"])
local store = require(root.store)
local Window = require(flakeComponents.Window)
local RoactRodux = require(libraries["roact-rodux"])
local InputLabel = require(flakeComponents.InputLabel)
local FormatNumber = require(root.FormatNumber.Simple)
local SetClientStatsVisible = require(actions.SetClientStatsVisible)

local formatNumber = FormatNumber.Format
local useMemo, useState, useEffect, createElement, createFragment = Roact.useMemo, Roact.useState, Roact.useEffect, Roact.createElement, Roact.createFragment
function StatItem(props)
    return createElement("TextLabel", {
        Text = props.children,
        Size = UDim2.fromScale(1, 0),
        TextSize = 12,
        FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
        TextColor3 = Color3.new(.9, .9, .9),
        LayoutOrder = props[1],
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

function getUsageByTag(tag: Enum.DeveloperMemoryTag)
    return Stats:GetMemoryUsageMbForTag(tag)
end

local frameAverage = {}
local ClientStats = RoactRodux.connect(function(state)
	return { visible = state.interface.clientStatsVisible }
end, function(dispatch)
	return { onClose = function()
        dispatch(SetClientStatsVisible(false))
    end }
end)(function(props)
    local fps, setFps = useState({0, 0})
    local showMem, setShowMem = useState(false)
    local stepper = useMemo(function()
        local frames = 0
        local elapsed = 0
        return RunService.Heartbeat:Connect(function(deltaTime)
            frames += 1
            elapsed += deltaTime
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
        end)
    end, {})
    useEffect(function()
        return function()
            frameAverage = {}
            stepper:Disconnect()
        end
    end, {})
    if not props.visible then
        return
    end

    local decimalMult = 10 ^ 2
    return createElement(Window, {
        icon = "rbxassetid://11568224787",
        title = "Client Statistics",
        height = 250,
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
            createElement("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            createElement(InputLabel, { LayoutOrder = 0 }, "General"),
            createElement(StatItem, {1}, string.format("FPS: %s (%s avg)", fps[1], fps[2])),
            createElement(StatItem, {2}, string.format("Instances: %s (%s nil)", formatNumber(Stats.InstanceCount), formatNumber(Stats.InstanceCount - #game:GetDescendants()))),
            createElement(StatItem, {3}, "Total Memory Usage: "..formatNumber(math.floor(Stats:GetTotalMemoryUsageMb())).." MB"),

            createElement(InputLabel, { LayoutOrder = 10 }, "Networking"),
            createElement(StatItem, {11}, "Data Receive: "..(math.modf(Stats.DataReceiveKbps * decimalMult) / decimalMult).." KB/s"),
            createElement(StatItem, {12}, "Data Send: "..(math.modf(Stats.DataSendKbps * decimalMult) / decimalMult).." KB/s"),

            createElement(StatItem, {13}, "Physics Receive: "..(math.modf(Stats.PhysicsReceiveKbps * decimalMult) / decimalMult).." KB/s"),
            createElement(StatItem, {14}, "Physics Send: "..(math.modf(Stats.PhysicsSendKbps * decimalMult) / decimalMult).." KB/s"),

            createElement(InputLabel, { LayoutOrder = 20 }, "Physics"),
            createElement(StatItem, {21}, "Primitives: "..formatNumber(Stats.PrimitivesCount)),
            createElement(StatItem, {22}, "Moving Primitives: "..formatNumber(Stats.MovingPrimitivesCount)),

            createElement(InputLabel, { LayoutOrder = 30 }, "Categorized Memory Usage"),
            not showMem and createElement("TextButton", {
                Text = "Click to show memory usage",
                TextSize = 14,
                FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
                TextColor3 = Color3.new(.6, .6, .6),
                LayoutOrder = 31,
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundTransparency = 1,
                [Roact.Event.Activated] = function()
                    setShowMem(true)
                end
            }),
            showMem and createFragment(llama.List.map(Enum.DeveloperMemoryTag:GetEnumItems(), function(item, key)
                return createElement(StatItem, {30 + key}, item.Name..": "..formatNumber(math.floor(getUsageByTag(item))).." MB")
            end))
        })
    })
end)

return function(props)
    return createElement(RoactRodux.StoreProvider, {
		store = store
	}, {
        createElement(ClientStats, props)
    })
end