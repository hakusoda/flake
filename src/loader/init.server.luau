--flake loader flake
local root = script.Parent
local localModule = root:FindFirstChildWhichIsA("ModuleScript")
require(localModule or root:GetAttribute("ModuleID")).new()