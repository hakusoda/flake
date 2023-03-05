--!strict
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local isServer = RunService:IsServer()

local root = script.Parent
local classes = root.classes

local data = require(script.data)
local types = require(root.types)
local baseSystem = require(classes.baseSystem)

local networking: types.networking = setmetatable({}, baseSystem) :: any
networking.__index = networking :: any
networking.name = "networking"

function networking.new(flake: types.flake)
	local self = setmetatable(baseSystem.new(flake), networking :: any) :: any
	self.emoji = "🔌"
	self.connection = flake.connection

	return self :: any
end

function networking:initialize()
    local self = self :: types.networking
	if isServer then
		self.key = HttpService:GenerateGUID()
		
		local acquiredFrom = {}
		self.requestKey = Instance.new("RemoteFunction")
		self.requestKey.Name = "requestKey"
		self.requestKey.Parent = script
		self.requestKey.OnServerInvoke = function(player: Player)
			if acquiredFrom[player] then
				return player:Kick()
			end
			
			acquiredFrom[player] = true
			return self.key
		end
		
		self.connection.OnServerEvent:Connect(function(player: Player, action: number, args: types.connectionArgs)
			self:onAction(player, action, args)
		end)
	else
		self.requestKey = script:WaitForChild("requestKey")
		repeat
			pcall(function()
				self.key = self.requestKey:InvokeServer()
			end)
			task.wait(5)
		until self.key
		
		self:log("received network key")
		self.connection.OnClientEvent:Connect(function(key: string, action: number, args: types.connectionArgs)
			if key == self.key then
				self:onAction(nil, action, args)
			end
		end)
	end

	self:log("initialized")
end

function networking:sendAction(action: number, args: types.connectionArgs)
	if isServer then
		self.connection:FireAllClients(self.key, action, args)
	else
		self.connection:FireServer(action, args)
	end
end

function networking:sendPlayerAction(player: Player, action: number, args: types.connectionArgs)
	assert(isServer, "sendPlayerAction can only be called by the server")

	self.connection:FireClient(player, self.key, action, args)
end

function networking:onAction(player: Player?, action: number, args: types.connectionArgs)
	assert(action, "Missing action argument")
	assert(args, "Missing args argument")

	local actionName
	for key, val in data.actions :: any do
		if action == val then
			actionName = key
		end
	end

	assert(actionName, "Action "..action.." not found")
	if isServer then
		assert(player, "Missing player argument")
		self:log("received action", actionName, "from", player.DisplayName, "("..player.Name..")")
	else
		self:log("received action", actionName, "from server")
	end

	data.callbacks[action](self.flake, player, args)
end

return networking