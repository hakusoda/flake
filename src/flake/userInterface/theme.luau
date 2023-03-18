--!strict
local root = script.Parent.Parent
local libraries = root.libraries

local Fusion = require(libraries.Fusion)
local Value, Computed = Fusion.Value, Fusion.Computed

function hsv(hue: number, saturation: number, value: number)
	return Color3.fromHSV(hue / 360, saturation / 100, value / 100)
end

export type theme = {
	textPrimary: Color3,
	textPrimary2: Color3,
	textSecondary: Color3,
	
	backgroundPrimary: Color3,
	backgroundSecondary: Color3,
	
	font400: Font,
	font500: Font
}
local theme = Value("dark")
local themes: { [string]: theme } = {
	dark = {
		textPrimary = hsv(310, 6, 86),
		textPrimary2 = hsv(310, 6, 96),
		textSecondary = hsv(310, 4, 64),
		
		backgroundPrimary = hsv(310, 10, 16),
		backgroundSecondary = hsv(310, 10, 20),
		
		font400 = Font.fromName("GothamSSm"),
		font500 = Font.fromName("GothamSSm", Enum.FontWeight.Medium)
	},
	light = {
		textPrimary = hsv(310, 6, 28),
		textPrimary2 = hsv(310, 6, 28),
		textSecondary = hsv(310, 4, 36),

		backgroundPrimary = hsv(310, 1, 86),
		backgroundSecondary = hsv(310, 1, 80),

		font400 = Font.fromName("GothamSSm"),
		font500 = Font.fromName("GothamSSm", Enum.FontWeight.Medium)
	}
}

local themeData = Computed(function()
	return themes[theme:get()]
end)

local metaCache = {}
local themeMeta = setmetatable({}, {
	__index = function(_,index)
		local cached = metaCache[index]
		if cached then
			return cached
		end
		
		local value = Computed(function()
			return themeData:get()[index]
		end)
		metaCache[index] = value
		
		return value
	end
})
return function(): (theme, Fusion.Value<string>)
	return themeMeta :: any, theme
end