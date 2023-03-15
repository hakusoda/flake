--!strict
local root = script.Parent
local helper = root.addonHelper

local types = require(helper.types)
local Fusion = require(helper.Fusion.PubTypes)
export type essentialsAddon = types.baseAddon & {
	clientInfoVisible: Fusion.Value<boolean>
}

return ""