--!strict
-- this system is responsible for handling
-- server & client communication for flake & addons
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local isServer = RunService:IsServer()

local root = script.Parent

local data = require(script.data)
local types = require(root.types)
local createSystem = require(root.helpers.createSystem)

local networking: types.networking, buildSystem = createSystem("networking", "📡")
function networking.new(flake: types.flake)
	local self = buildSystem(flake)
	self.connection = flake.connection

	return self
end

function networking:initialise()
    local self = self :: types.networking
	if isServer then
		-- TODO: use a different generation method
		self.key = HttpService:GenerateGUID()
		
		local acquiredFrom = {}
		self.requestKey = Instance.new("RemoteFunction")
		self.requestKey.Name = "requestKey"
		self.requestKey.Parent = script
		self.requestKey.OnServerInvoke = function(player)
			if acquiredFrom[player] then
				return player:Kick() -- only once!
			end
			
			acquiredFrom[player] = true
			return self.key
		end
		
		self.connection.OnServerEvent:Connect(function(player, action: number, args: types.connectionArgs)
			self:onAction(player, action, args)
		end)
	else
		self.requestKey = script:WaitForChild("requestKey")
		
		repeat
			xpcall(function()
				self.key = self.requestKey:InvokeServer()
			end, function()
				self:log("key request failed, retrying in 5 seconds")
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

	self:log("initialised")
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
	for name, value in data.actions :: { [string]: number } do
		if action == value then
			actionName = name
			break
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