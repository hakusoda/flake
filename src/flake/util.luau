--!strict
local root = script.Parent
local libraries = root.libraries

local types = require(root.types)
local llama = require(libraries.llama)

local util = {}
function util.authorsToString(authors: {any})
	return table.concat(llama.List.map(authors, function(item: any)
		return typeof(item) == "string" and item or item.name
	end), ", ")
end

function util.getAddonIcon(icon: string | types.addonIcon): types.addonIcon
	if typeof(icon) == "string" then
		return {
			main = icon,
			list = icon
		}
	else
		return {
			main = icon.main or icon.list or "",
			list = icon.list or icon.main or ""
		}
	end
end

return util