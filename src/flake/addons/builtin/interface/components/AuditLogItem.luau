--!strict
local RunService = game:GetService("RunService")

local root = script.Parent.Parent.Parent.Parent.Parent
local libraries = root.libraries

local t = require(root.localisation)()
local types = require(root.types)
local Fusion = require(libraries.Fusion)
local images = require(root.userInterface.images)

local New, Value, Children, Computed = Fusion.New, Fusion.Value, Fusion.Children, Fusion.Computed
function s(passed: number)
	return passed == 1 and "" or "s"
end
function calcTimeAgo(time: number)
	local now = os.time()
	local second = now - time
	if second >= 3600 then
		local hour = math.floor(second / 3600)
		return `{hour} hour{s(hour)} ago`
	elseif second >= 60 then
		local minute = math.floor(second / 60)
		return `{minute} minute{s(minute)} ago`
	end
	return `{second} second{s(second)} ago`
end
function timeAgo(time: number)
	local value = Value(calcTimeAgo(time))
	local lastCheck = os.clock()
	return value, RunService.PreSimulation:Connect(function()
		local clock = os.clock()
		if (clock - lastCheck) > 1 then
			value:set(calcTimeAgo(time))
		end
	end)
end

export type AuditLogItemProps = {
	key: number,
	data: types.auditLog
}
return function(props: AuditLogItemProps)
	local data = props.data
	local player = data.player
	local action = t(`audit-log-action.{data.actionType}`)
	return New "Frame" {
		Size = UDim2.new(1, 0, 0, 56),
		LayoutOrder = -props.key,
		BackgroundColor3 = Color3.fromRGB(45, 45, 45),
		[Children] = {
			New "UICorner" {},
			New "UIPadding" {
				PaddingTop = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 8)
			},
			New "Frame" {
				Transparency = 1,
				AutomaticSize = Enum.AutomaticSize.XY,
				[Children] = {
					New "ImageLabel" {
						Size = UDim2.fromOffset(40, 40),
						Image = player and `rbxthumb://id={player.UserId}&w=48&h=48&type=AvatarHeadShot` or images.PLACEHOLDER_ICON2,
						BackgroundColor3 = Color3.fromRGB(55, 55, 55),
						[Children] = New "UICorner" {
							CornerRadius = UDim.new(0, 4)
						}
					},
					New "Frame" {
						Size = UDim2.fromOffset(0, 40),
						Position = UDim2.fromOffset(48, 0),
						Transparency = 1,
						[Children] = {
							New "UIListLayout" {
								Padding = UDim.new(0, 1),
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Center
							},
							New "TextLabel" {
								Text = Computed(function()
									return `{player and `@{player.Name}` or "Server"} <font color=\"#969696\">{action:get()}</font> {data.target}`
								end),
								TextSize = 13,
								RichText = true,
								FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Medium),
								TextColor3 = Color3.new(.8, .8, .8),
								AutomaticSize = Enum.AutomaticSize.XY,
								BackgroundTransparency = 1
							},
							New "TextLabel" {
								Text = timeAgo(data.time),
								TextSize = 12,
								RichText = true,
								FontFace = Font.fromName("GothamSSm"),
								TextColor3 = Color3.new(.6, .6, .6),
								LayoutOrder = 1,
								AutomaticSize = Enum.AutomaticSize.XY,
								BackgroundTransparency = 1
							}
						}
					}
				}
			}
		}
	}
end