--!strict
local root = script.Parent.Parent.Parent.Parent
local types = require(root.types)
local Fusion = require(root.libraries.Fusion)
export type interfaceAddon = types.baseAddon & {
	viewAddon: Fusion.Value<types.baseAddon?>,
	auditLogVisible: Fusion.Value<boolean>,
	flakeInfoVisible: Fusion.Value<boolean>,
	commandListVisible: Fusion.Value<boolean>
}
return ""