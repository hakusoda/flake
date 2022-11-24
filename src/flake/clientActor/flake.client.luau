--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local module = ReplicatedStorage:WaitForChild("flakeModule")
require(module).new()