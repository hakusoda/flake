-- flake flake flake flake

-- flake is an open-source, modern & experimental Roblox Admin System created by Voxelified 😊

local root = script.Parent
local localModule = root:FindFirstChildWhichIsA("ModuleScript")
require(localModule or root:GetAttribute("ModuleID")).startFlake()