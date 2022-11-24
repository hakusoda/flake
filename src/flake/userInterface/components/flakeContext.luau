--!strict
local root = script.Parent.Parent.Parent
local libraries = root:WaitForChild("libraries")

local Roact = require(libraries:WaitForChild("roact-compat"))
return Roact.createContext(nil)