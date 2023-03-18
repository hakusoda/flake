--!strict
local RunService = game:GetService("RunService")

local root = script.Parent.Parent.Parent.Parent.Parent
local libraries = root.libraries

local t = require(root.localisation)()
local types = require(root.types)
local theme = require(root.userInterface.theme)()
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
		BackgroundColor3 = theme.backgroundSecondary,
		[Children] = {
			New "UICorner" {},
			New "UIPadding" {
				PaddingTop = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 8)
			},
			New "ImageLabel" {
				Size = UDim2.fromOffset(40, 40),
				Image = player and `rbxthumb://id={player.UserId}&w=48&h=48&type=AvatarHeadShot` or images.PLACEHOLDER_ICON2,
				BackgroundColor3 = theme.backgroundPrimary,
				[Children] = New "UICorner" {
					CornerRadius = UDim.new(0, 4)
				}
			},
			New "TextLabel" {
				Size = UDim2.fromOffset(0, 13),
				Text = Computed(function()
					return `{player and `@{player.Name}` or "Server"} <font color=\"#{(theme.textSecondary :: any):get():ToHex()}\">{action:get()}</font> {data.target}`
				end),
				TextSize = 13,
				RichText = true,
				FontFace = theme.font500,
				Position = UDim2.fromOffset(48, 7),
				TextColor3 = theme.textPrimary,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1
			},
			New "TextLabel" {
				Text = timeAgo(data.time),
				Size = UDim2.fromOffset(0, 12),
				TextSize = 12,
				RichText = true,
				FontFace = theme.font500,
				Position = UDim2.fromOffset(48, 21),
				TextColor3 = theme.textSecondary,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1
			}
		}
	}
end