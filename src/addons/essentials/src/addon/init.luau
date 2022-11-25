--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local isClient = RunService:IsClient()
local localPlayer = Players.LocalPlayer

local flake = ReplicatedStorage.flake

local Cryo = require(script:WaitForChild("Cryo"))
local vLua = require(script:WaitForChild("vLua"))
local types = require(script:WaitForChild("types"))
local baseAddon: types.baseAddon = require(flake:WaitForChild("baseAddon"))

type essentialsAddon = types.baseAddon & {
	createCommand: (self: essentialsAddon, id: string) -> types.command
}
local actions = {
	TEST2 = 0
}

local essentialsAddon: essentialsAddon = setmetatable({}, baseAddon) :: any
essentialsAddon.__index = essentialsAddon :: any
essentialsAddon.id = "essentials"
essentialsAddon.name = "flake Essentials"
essentialsAddon.authors = {"Voxelified"}
essentialsAddon.description = "Useful commands & such for flake"
essentialsAddon.version = "1.0.0"

function essentialsAddon.new(system)
	local self: any = setmetatable(baseAddon.new(system), essentialsAddon :: any)
	self.actions = actions

	return self
end

function essentialsAddon:initialize()
	local self = self :: essentialsAddon

	self:createCommand("essentials-kill")
	:setAlias("kill")
	:setLevel(1)
	:setContext("server")
	:addArgument("targets", "players")
	:onCallback(function(cmd, executor: Player, targets: {Player})
		for _,target in pairs(targets) do
			local character = target.Character
			if character then
				local humanoid = character:FindFirstChildWhichIsA("Humanoid")
				if humanoid then
					humanoid.Health = 0
					humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				end
			end
		end
	end)

	self:createCommand("essentials-sit")
	:setAlias("sit")
	:setLevel(1)
	:setContext("server")
	:addArgument("targets", "players")
	:onCallback(function(cmd, executor: Player, targets: {Player})
		for _,target in pairs(targets) do
			local character = target.Character
			if character then
				local humanoid = character:FindFirstChildWhichIsA("Humanoid")
				if humanoid then
					humanoid.Sit = true
				end
			end
		end
	end)

	self:createCommand("essentials-respawn")
	:setAlias("respawn")
	:setLevel(1)
	:setContext("server")
	:addArgument("targets", "players")
	:onCallback(function(cmd, executor: Player, targets: {Player})
		for _,target in pairs(targets) do
			task.defer(target.LoadCharacter, target)
		end
	end)

	self:createCommand("essentials-test")
	:setAlias("test")
	:setLevel(0)
	:setContext("server")
	:addArgument("text", "string", "rest")
	:onCallback(function(cmd, executor: Player, text: string)
		self.flake:notifyPlayer(executor, "Test notification", text)
	end)

	self:createCommand("essentials-test2")
	:setAlias("test2")
	:setLevel(0)
	:setContext("server")
	:onCallback(function(cmd, executor: Player)
		self:sendPlayerAction(executor, actions.TEST2, {})
	end)

	self:createCommand("essentials-teleport-to")
	:setAlias("goto", "to")
	:setLevel(1)
	:setContext("server")
	:addArgument("targets", "players")
	:onCallback(function(cmd, executor: Player, targets: {Player})
		local character = executor.Character
		if character then
			local character2 = targets[1].Character
			if character2 then
				character:PivotTo(character2:GetPivot() * CFrame.new(0, 0, -2))
			end
		end
	end)

	self:createCommand("essentials-teleport-bring")
	:setAlias("bring")
	:setLevel(1)
	:setContext("server")
	:addArgument("targets", "players")
	:onCallback(function(cmd, executor: Player, targets: {Player})
		local character = executor.Character
		if character then
			for _,target in pairs(targets) do
				task.defer(function()
					local character2 = target.Character
					if character2 then
						character2:PivotTo(character:GetPivot() * CFrame.new(0, 0, -2))
					end
				end)
			end
		end
	end)

	self:createCommand("essentials-rejoin")
	:setAlias("rejoin")
	:setLevel(0)
	:setContext("server")
	:onCallback(function(cmd, executor: Player)
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, executor, nil, nil)
	end)

	self:createCommand("essentials-respawn")
	:setAlias("respawn")
	:setLevel(1)
	:setContext("server")
	:addArgument("targets", "players")
	:onCallback(function(cmd, executor: Player, targets: {Player})
		for _,player in pairs(targets) do
			task.defer(player.LoadCharacter, player)
		end
	end)

	self:createCommand("essentials-refresh")
	:setAlias("refresh")
	:setLevel(1)
	:setContext("server")
	:addArgument("targets", "players")
	:onCallback(function(cmd, executor: Player, targets: {Player})
		for _,player in pairs(targets) do
			task.defer(function()
				local tools1 = Cryo.List.filterMap(player:WaitForChild("Backpack"):GetChildren(), function(child)
					return child:IsA("Tool") and child:Clone() or nil
				end)
				local tools2 = {}
				local character = player.Character
                local position
				if character then
					tools2 = Cryo.List.filterMap(character:GetChildren(), function(child)
						return child:IsA("Tool") and child:Clone() or nil
					end)
					local humanoid = character:FindFirstChildWhichIsA("Humanoid")
					if humanoid then
                        if humanoid.RootPart then
                            position = humanoid.RootPart.CFrame
                        end
						humanoid:UnequipTools()
						task.wait()
                    elseif character.PrimaryPart then
                        position = character.PrimaryPart.CFrame
					end
				end
				player:LoadCharacter()

                print(tools1, tools2)
				local character = player.Character or player.CharacterAdded:Wait()
				local backpack = player:WaitForChild("Backpack")
				for _,i in pairs(tools1) do
					i.Parent = backpack
				end

				local humanoid = character:WaitForChild("Humanoid", 5)
				if humanoid then
					for _,i in pairs(tools2) do
                        i.Parent = character
						humanoid:EquipTool(i)
					end
                    if humanoid.RootPart and position then
                        humanoid.RootPart.CFrame = position
                    end
                elseif character.PrimaryPart and position then
                    for _,i in pairs(tools2) do
						i.Parent = character
					end
                    character.PrimaryPart.CFrame = position
				end
			end)
		end
	end)

	self:createCommand("essentials-walk-speed")
	:setAlias("walkspeed", "speed")
	:setLevel(1)
	:setContext("server")
	:addArgument("targets", "players")
	:addArgument("value", "number")
	:onCallback(function(cmd, executor: Player, targets: {Player}, value: number)
		for _,player in pairs(targets) do
			task.defer(function()
				local character = player.Character
				if character then
					local humanoid = character:FindFirstChildWhichIsA("Humanoid")
					if humanoid then
						humanoid.WalkSpeed = value
					end
				end
			end)
		end
		self.flake:notifyPlayer(executor, nil, "Set the walk-speed of "..#targets.." player(s) to <b>"..value.."</b>.")
	end)

	self:createCommand("essentials-jump-power")
	:setAlias("jumppower")
	:setLevel(1)
	:setContext("server")
	:addArgument("targets", "players")
	:addArgument("value", "number")
	:onCallback(function(cmd, executor: Player, targets: {Player}, value: number)
		for _,player in pairs(targets) do
			task.defer(function()
				local character = player.Character
				if character then
					local humanoid = character:FindFirstChildWhichIsA("Humanoid")
					if humanoid then
						humanoid.UseJumpPower = true
						humanoid.JumpPower = value
					end
				end
			end)
		end
		self.flake:notifyPlayer(executor, nil, "Set the jump-power of "..#targets.." player(s) to <b>"..value.."</b>.")
	end)

	self:createCommand("essentials-jump-height")
	:setAlias("jumpheight")
	:setLevel(1)
	:setContext("server")
	:addArgument("targets", "players")
	:addArgument("value", "number")
	:onCallback(function(cmd, executor: Player, targets: {Player}, value: number)
		for _,player in pairs(targets) do
			task.defer(function()
				local character = player.Character
				if character then
					local humanoid = character:FindFirstChildWhichIsA("Humanoid")
					if humanoid then
						humanoid.UseJumpPower = false
						humanoid.JumpHeight = value
					end
				end
			end)
		end
		self.flake:notifyPlayer(executor, nil, "Set the jump-height of "..#targets.." player(s) to <b>"..value.."</b>.")
	end)

	self:createCommand("essentials-kick")
	:setAlias("kick")
	:setLevel(1)
	:setContext("server")
	:addArgument("targets", "players")
	:addArgument("reason", "string", "rest")
	:onCallback(function(cmd, executor: Player, targets: {Player}, reason: string)
		for _,player in pairs(targets) do
			task.defer(player.Kick, player, reason)
		end
		self.flake:notifyPlayer(executor, nil, "Kicked <b>"..#targets.."</b> player(s).")
	end)

	self:createCommand("essentials-freecam")
	:setAlias("freecam")
	:setLevel(1)
	:setContext("client")
	:onCallback(function(cmd, executor: Player)
		local playerGui = executor:WaitForChild("PlayerGui")
		local gui = playerGui:FindFirstChild("Freecam") or script.Freecam:Clone()
		gui.Parent = playerGui

		self.flake:notifyPlayer(executor, nil, "Press Shift + P to use Freecam.")
	end)

	self:createCommand("essentials-eval-server")
	:setAlias("evalserver")
	:setLevel(1)
	:setContext("server")
	:addArgument("code", "string", "rest")
	:onCallback(function(cmd, executor: Player, code: string)
		local execute, failure = vLua(code)
		if failure then
			self.flake:notifyPlayer(executor, "Eval failure", failure)
		else
			self.flake:notifyPlayer(executor, nil, "Executed code")
			execute()
		end
	end)

	self:createCommand("essentials-eval-client")
	:setAlias("evalclient")
	:setLevel(1)
	:setContext("client")
	:addArgument("code", "string", "rest")
	:onCallback(function(cmd, executor: Player, code: string)
		local execute, failure = vLua(code)
		if failure then
			self.flake.userInterface:notify("Eval failure", failure)
		else
			self.flake.userInterface:notify(nil, "Executed code")
			execute()
		end
	end)

	self:createCommand("essentials-notify")
	:setAlias("notify")
	:setLevel(1)
	:setContext("server")
	:addArgument("targets", "players")
	:addArgument("text", "string", "rest")
	:onCallback(function(cmd, executor: Player, targets: {Player}, text: string)
		for _,target in pairs(targets) do
			self.flake:notifyPlayer(target, "Notication from <b>"..executor.DisplayName.."</b>", text)
		end
	end)

	self:createCommand("essentials-reset-velocity")
	:setAlias("resetvelocity", "resetvel")
	:setLevel(1)
	:setContext("server")
	:addArgument("targets", "players")
	:onCallback(function(cmd, executor: Player, targets: {Player})
		for _,target in pairs(targets) do
			task.defer(function()
				local character = target.Character
				if character then
					for _,i: BasePart in pairs(character:GetDescendants()) do
						if i:IsA("BasePart") then
							i.AssemblyLinearVelocity = Vector3.zero
							i.AssemblyAngularVelocity = Vector3.zero
						end
					end
				end
			end)
		end
	end)

	self:createCommand("essentials-freeze")
	:setAlias("freeze")
	:setLevel(1)
	:setContext("server")
	:addArgument("targets", "players")
	:onCallback(function(cmd, executor: Player, targets: {Player})
		for _,target in pairs(targets) do
			task.defer(function()
				local character = target.Character
				if character and character.PrimaryPart then
					character.PrimaryPart.Anchored = true
					self.flake:notifyPlayer(target, nil, "You have been frozen.")
				end
			end)
		end
		self.flake:notifyPlayer(executor, nil, #targets.." player(s) have been frozen.")
	end)

	self:createCommand("essentials-unfreeze")
	:setAlias("unfreeze")
	:setLevel(1)
	:setContext("server")
	:addArgument("targets", "players")
	:onCallback(function(cmd, executor: Player, targets: {Player})
		for _,target in pairs(targets) do
			task.defer(function()
				local character = target.Character
				if character and character.PrimaryPart then
					character.PrimaryPart.Anchored = false
					self.flake:notifyPlayer(target, nil, "You have been unfrozen.")
				end
			end)
		end
		self.flake:notifyPlayer(executor, nil, #targets.." player(s) have been unfrozen.")
	end)

    self:createCommand("essentials-r15")
	:setAlias("r15")
	:setLevel(1)
	:setContext("server")
	:addArgument("targets", "players")
	:onCallback(function(cmd, executor: Player, targets: {Player})
		for _,target in pairs(targets) do
			task.defer(function()
                local desc = Players:GetHumanoidDescriptionFromUserId(target.UserId)
				local new = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)

                local char = target.Character
                target.Character = new

                new.Parent = workspace
                new:PivotTo(char:GetPivot())

                char:Destroy()
			end)
		end
	end)

    self:createCommand("essentials-r6")
	:setAlias("r6")
	:setLevel(1)
	:setContext("server")
	:addArgument("targets", "players")
	:onCallback(function(cmd, executor: Player, targets: {Player})
		for _,target in pairs(targets) do
			task.defer(function()
                local desc = Players:GetHumanoidDescriptionFromUserId(target.UserId)
				local new = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R6)

                local char = target.Character
                target.Character = new

                new.Parent = workspace
                new:PivotTo(char:GetPivot())

                char:Destroy()
			end)
		end
	end)

	local flying = false
	self:createCommand("essentials-fly")
	:setAlias("fly")
	:setLevel(1)
	:setContext("client")
	:onCallback(function()
		flying = not flying
	end)

	if isClient then
		RunService.Heartbeat:Connect(function()
			if flying then
				local character = localPlayer.Character
				if character then
					local humanoid: Humanoid = character.Humanoid
					local rootPart: BasePart = character.PrimaryPart or humanoid.RootPart
					rootPart.AssemblyLinearVelocity = Vector3.zero
					rootPart.AssemblyAngularVelocity = Vector3.zero
				end
			end
		end)
	end
end

function essentialsAddon:onAction(player: Player?, action: number, args: types.connectionArgs)
	baseAddon.onAction(self :: any, player, action, args)

	if action == actions.TEST2 then
		if isClient then
			self.flake.userInterface:notify("Test notification", "Received action from server!")
		end
	end
end

function essentialsAddon:createCommand(id: string): types.command
	return self.flake.commandSystem:create(id)
end

return essentialsAddon