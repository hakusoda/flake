--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")

local isStudio = RunService:IsStudio()
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()

local root = script.Parent
local classes = root.classes
local libraries = root.libraries

local types = require(root.types)
local llama = require(libraries.llama)
local supabase = require(libraries.supabase)
local baseSystem = require(classes.baseSystem)

local cloud: types.cloud = setmetatable({}, baseSystem) :: any
cloud.__index = cloud :: any
cloud.name = "cloud"

function cloud.new(flake: types.flake)
	local self: types.cloud = setmetatable(baseSystem.new(flake), cloud :: any) :: any
	self.emoji = "☁️"
	self.restUrl = "https://cloud-api.flake.voxelified.com/v1"
	
	if isServer then -- yes, this is using a public key :)
		local config = ServerStorage:FindFirstChild("flakeCloud")
		assert(config, "ServerStorage.flakeCloud is missing")
		
		-- TODO: config validation
		self.config2 = require(config)
		
		self.supabase = supabase.new("https://gzlrrsjtbzflasxukxki.supabase.co", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd6bHJyc2p0YnpmbGFzeHVreGtpIiwicm9sZSI6ImFub24iLCJpYXQiOjE2Nzg0MjkxMzIsImV4cCI6MTk5NDAwNTEzMn0.Oa6e0l9cvK0_7H9g6vGFpLfBorQOGVU7bxHqSfjaj40")
		self.supabase.rest.schema = "flake"
	end

	return self
end

function cloud:initialize()
	local self = self :: types.cloud
	local config = self.flake.config.cloud
	if isServer then
		self.serverCloudId = self:request("server/start", "POST", {
			players = {},
			version = self.flake.version
		}).id
		
		local players = Players:GetPlayers()
		if #players > 0 then
			self:updatePlayers(players)
		end
		
		Players.PlayerAdded:Connect(function(player)
			table.insert(players, player)
			self:updatePlayers(players)
		end)
		Players.PlayerRemoving:Connect(function(player)
			players = llama.List.removeValue(players, player)
			self:updatePlayers(players)
		end)
		
		game:BindToClose(function()
			self.flake.serverClosed = true
			self:request("server/stop")
			task.wait(5)
		end)
		
		task.defer(function()
			repeat task.wait(config.updateInterval)
				xpcall(function()
					local data = self:request("server/get").data
					if data.shutdown then
						self.flake:closeServer()
					end
				end, warn)
			until self.flake.serverClosed
		end)
	end
	
	self:log("initialized")
end

function cloud:updatePlayers(list: {Player})
	if not self.flake.serverClosed then
		self:request("server/update", "POST", {
			players = llama.List.map(list, function(player: Player)
				return { id = player.UserId }
			end)
		})
	end
end

local JOB_ID = isStudio and HttpService:GenerateGUID(false) or game.JobId
local UNIVERSE_ID = tostring(game.GameId)
function cloud:request<T>(path: string, method: 'GET' | 'POST'?, body: any?)
	local response = HttpService:RequestAsync({
		Url = `{self.restUrl}/{path}`,
		Body = body and HttpService:JSONEncode(body) or nil,
		Method = method or "POST",
		Headers = {
			["roblox-job"] = JOB_ID,
			["roblox-uni"] = UNIVERSE_ID,
			["x-access-key"] = self.config2.accessKey,
			["Content-Type"] = "application/json"
		}
	})
	assert(response.Success, response.Body)
	
	return HttpService:JSONDecode(response.Body)
end

return cloud