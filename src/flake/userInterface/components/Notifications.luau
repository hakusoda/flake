--!strict
local root = script.Parent.Parent
local flake = root.Parent
local libraries = flake.libraries
local components = script.Parent

local Cryo = require(libraries.llama)
local Roact = require(libraries["roact-compat"])
local RoactRodux = require(libraries["roact-rodux"])
local Notification = require(components.Notification)

local useRef, createElement = Roact.useRef, Roact.createElement
return RoactRodux.connect(function(state)
	return { data = state.notifications }
end)(function(props)
    local frameRef = useRef(nil)
    local function updateOrder()
        local frame = frameRef.current
        if frame then
            local height = 0
            for _,child in pairs(Cryo.List.reverse(frame:GetChildren())) do
                if child:IsA("Frame") and child.Visible then
                    child.Position = UDim2.new(0, 0, 1, -height)
                    height += child.AbsoluteSize.Y + 8
                end
            end
        end
    end

    return createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromOffset(0, -16),
		BackgroundTransparency = 1,
		[Roact.Ref] = frameRef
	}, {
		createElement("UIPadding", {
			PaddingTop = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 2)
		}),
		table.unpack(Cryo.List.map(props.data, function(data)
			return createElement(Notification, {
				data = data,
				update = updateOrder
			})
		end))
	})
end)