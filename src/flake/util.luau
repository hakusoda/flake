--!strict
local root = script.Parent
local libraries = root.libraries

local types = require(root.types)
local llama = require(libraries.llama)

local util = {}
function util.authorsToString(authors: {string | types.addonAuthor})
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

function util.getAddonAuthor(author: string | types.addonAuthor): types.addonAuthor
	if typeof(author) == "string" then
		return {
			name = author,
			icon = "rbxassetid://11259235980"
		}
	else
		return {
			name = author.name or "Anonymous",
			icon = author.icon or "rbxassetid://11259235980"
		}
	end
end

function util.concat<T>(t1: { T }, t2: { T }): { T }
	local new = table.create(#t1 + #t2)
	table.move(t1, 1, #t1, 1, new)
	table.move(t2, 1, #t2, #t1 + 1, new)
	
	return new
end

return util