--!strict
local RunService = game:GetService("RunService")

local root = script.Parent.Parent.Parent.Parent.Parent
local libraries = root.libraries
local userInterface = root.userInterface
local components = userInterface.components

local t = require(root.localisation)()
local Icon = require(components.Icon)
local Text = require(components.Text)
local types = require(root.types)
local theme = require(userInterface.theme)()
local Fusion = require(libraries.Fusion)
local images = require(userInterface.images)

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
		Position = UDim2.fromOffset(0, 64 * (props.key - 1)),
		BackgroundColor3 = theme.backgroundSecondary,
		[Children] = {
			New "UICorner" {},
			Icon(player and `rbxthumb://id={player.UserId}&w=48&h=48&type=AvatarHeadShot` or images.PLACEHOLDER_ICON2, 40, 8, 8),
			Text(Computed(function()
				return `{player and `@{player.Name}` or "Server"} <font color=\"#{(theme.textSecondary :: any):get():ToHex()}\">{action:get()}</font> {data.target}`
			end), 13, UDim2.fromOffset(56, 15), nil, true),
			Text(timeAgo(data.time), 12, UDim2.fromOffset(56, 29), theme.textSecondary)
		}
	}
end