--!strict
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local root = script.Parent.Parent
local flake = (ReplicatedStorage :: any).flakeModule
local actions = root.store.actions
local libraries = flake.libraries
local userInterface = flake.userInterface
local flakeComponents = userInterface.components

local store = require(root.store)
local Roact = require(libraries["roact-compat"])
local Window = require(flakeComponents.Window)
local RoactRodux = require(libraries["roact-rodux"])
local InputLabel = require(flakeComponents.InputLabel)
local SetExampleVisible = require(actions.SetExampleVisible)

local useMemo, useState, useEffect, createElement = Roact.useMemo, Roact.useState, Roact.useEffect, Roact.createElement

local Example = RoactRodux.connect(function(state)
	return { visible = state.interface.exampleVisible }
end, function(dispatch)
	return { onClose = function()
        dispatch(SetExampleVisible(false))
    end }
end)(function(props)
	-- clock example because why not :)
	local time, setTime = useState(0) -- we use "useState" to keep our time variable between renders!
	local clock = useMemo(function()
		local last = 0
		return RunService.Heartbeat:Connect(function()
			local time = tick()
			if time - last > 1 then
				print('yea')
				last = time
				setTime(function(value)
					return value + 1
				end)
			end
		end)
	end, {}) -- we use this {} argument to make our function only run once per mount!

	useEffect(function()
		-- this function runs when our roact component is dismounted
		return function()
			-- this disconnects the RBXScriptConnection, which stops the clock above!
			clock:Disconnect()
		end
	end, {})

	if not props.visible then
		return
	end

	return createElement(Window, {
		icon = "rbxassetid://11568224787",
		title = "Example!",
		height = 100,
		hidden = not props.visible,
		onClose = props.onClose
	}, {
		createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder
		}),

		createElement(InputLabel, {}, "Clock"),
		createElement("TextLabel", {
			Text = time.." seconds have passed!",
			TextSize = 12,
			FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
			TextColor3 = Color3.new(.9, .9, .9),
			LayoutOrder = 1,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1
		})
	})
end)

return function(props)
	return createElement(RoactRodux.StoreProvider, {
		store = store
	}, {
		createElement(Example, props)
	})
end