--!strict
local root = script.Parent
local types = require(root.flakeTypes)
local Fusion = require(root.Fusion)
export type essentialsAddon = types.baseAddon & {
	clientInfoVisible: Fusion.Value<boolean>,

	createCommand: (self: essentialsAddon, id: string) -> types.command
}

return ""