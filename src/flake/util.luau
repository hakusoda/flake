--!strict
local root = script.Parent
local libraries = root.libraries

local llama = require(libraries.llama)

local util = {}
function util.authorsToString(authors: {any})
	return table.concat(llama.List.map(authors, function(item: any)
		return typeof(item) == "string" and item or item.name
	end), ", ")
end

return util