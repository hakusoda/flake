--!strict
local root = script.Parent.Parent
local flake = root.Parent
local actions = flake.store.actions
local libraries = flake.libraries
local components = script.Parent

local Cryo = require(libraries.llama)
local types = require(flake.types)
local Roact = require(libraries["roact-compat"])
local Window = require(components.Window)
local RoactRodux = require(libraries["roact-rodux"])
local flakeContext = require(components.flakeContext)
local SetFlakeInfoVisible = require(actions.SetFlakeInfoVisible)

local createElement = Roact.createElement
return RoactRodux.connect(function(state)
	return { visible = state.interface.infoVisible }
end, function(dispatch)
	return { onClose = function()
        dispatch(SetFlakeInfoVisible(false))
    end }
end)(function(props)
	return createElement(flakeContext.Consumer, {
		render = function(flake: types.flake)
			local addons = Cryo.Dictionary.values(flake.addons.addons)
			return createElement(Window, {
				icon = "rbxassetid://11260520498",
				title = "flake info",
				width = 350,
				height = 208,
				hidden = not props.visible,
				onClose = props.onClose
			}, {
				createElement("UIListLayout", {
					Padding = UDim.new(0, 16)
				}),
				createElement("Frame", {
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundTransparency = 1
				}, {
					createElement("ImageLabel", {
						Size = UDim2.fromOffset(64, 64),
						Image = "rbxassetid://11259281331",
						BackgroundTransparency = 1
					}),
					createElement("Frame", {
						Size = UDim2.fromOffset(0, 64),
						Position = UDim2.fromOffset(80, 0),
						BackgroundTransparency = 1
					}, {
						createElement("UIListLayout", {
							Padding = UDim.new(0, 4),
							VerticalAlignment = Enum.VerticalAlignment.Center
						}),
						createElement("TextLabel", {
							Text = "flake <font size=\"12\" color=\"#c8c8c8\">v"..flake.version.."</font>",
							TextSize = 16,
							RichText = true,
							FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Medium),
							TextColor3 = Color3.new(1, 1, 1),
							AutomaticSize = Enum.AutomaticSize.XY,
							BackgroundTransparency = 1
						}),
						createElement("TextLabel", {
							Text = "A simple, modern admin system.",
							TextSize = 12,
							FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
							TextColor3 = Color3.fromRGB(240, 240, 240),
							AutomaticSize = Enum.AutomaticSize.XY,
							BackgroundTransparency = 1
						})
					})
				}),
				createElement("Frame", {
					Size = UDim2.fromScale(1, 0),
					BackgroundTransparency = 1
				}, {
					createElement("TextLabel", {
						Text = "This experience is using "..#addons.." addons:",
						TextSize = 12,
						FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
						TextColor3 = Color3.fromRGB(240, 240, 240),
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1
					}),
					createElement("ScrollingFrame", {
						Size = UDim2.new(1, 0, 0, 56),
						Position = UDim2.fromOffset(0, 18),
						ScrollBarThickness = 4,
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1
					}, {
						createElement("UIListLayout", {
							Padding = UDim.new(0, 8)
						}),
						table.unpack(Cryo.List.map(addons, function(addon: types.baseAddon)
							return createElement("Frame", {
								Size = UDim2.new(1, 0, 0, 56),
								BackgroundColor3 = Color3.fromRGB(70, 70, 70)
							}, {
								createElement("UICorner", {
									CornerRadius = UDim.new(0, 8)
								}),
								createElement("UIGradient", {
									Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(203, 211, 226)),
									Rotation = 90
								}),
							    createElement("UIPadding", {
									PaddingTop = UDim.new(0, 8),
									PaddingLeft = UDim.new(0, 8),
									PaddingRight = UDim.new(0, 8),
									PaddingBottom = UDim.new(0, 8)
								}),
								createElement("Frame", {
									AutomaticSize = Enum.AutomaticSize.XY,
									BackgroundTransparency = 1
								}, {
									createElement("ImageLabel", {
										Size = UDim2.fromOffset(40, 40),
										Image = addon.icon,
										BackgroundTransparency = 1
									}, {
										createElement("UICorner", {
											CornerRadius = UDim.new(0, 4)
										})
									}),
									createElement("Frame", {
										Size = UDim2.fromOffset(0, 40),
										Position = UDim2.fromOffset(48, 0),
										BackgroundTransparency = 1
									}, {
										createElement("UIListLayout", {
											Padding = UDim.new(0, 1),
											VerticalAlignment = Enum.VerticalAlignment.Center
										}),
										createElement("TextLabel", {
											Text = (addon.name or addon.id).." <font size=\"8\" color=\"#c8c8c8\">v"..(addon.version or "0.0.0").." by "..addon.authors[1].."</font>"..(string.find(addon.id, "builtin") == 1 and "   <font size=\"8\" color=\"#c8c8c8\"><sc>(BUILT-IN ADDON)</sc></font>" or ""),
											TextSize = 12,
											RichText = true,
											FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Medium),
											TextColor3 = Color3.new(1, 1, 1),
											AutomaticSize = Enum.AutomaticSize.XY,
											BackgroundTransparency = 1
										}),
										createElement("TextLabel", {
											Text = addon.description or "description",
											TextSize = 10,
											FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Regular),
											TextColor3 = Color3.fromRGB(240, 240, 240),
											AutomaticSize = Enum.AutomaticSize.XY,
											BackgroundTransparency = 1
										})
									})
								})
							})
						end))
					})
				})
			})
		end
	})
end)