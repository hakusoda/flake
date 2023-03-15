--!strict
-- responsible for handling localisation of the user interface
-- also known as the worst looking part of flake (code bad)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalizationService = game:GetService("LocalizationService")

local root = script.Parent
local libraries = root.libraries

local Fusion = require(libraries.Fusion)
local Value, Computed = Fusion.Value, Fusion.Computed

local userLocale = ""
local translator: Translator = RunService:IsClient() and LocalizationService:GetTranslatorForPlayer(Players.LocalPlayer) or nil
if translator then
	userLocale = translator.LocaleId
end

local sourceLocale = "en-au"
local data = {
	["en-au"] = require(script["en-au"]),
	["ja-jp"] = require(script["ja-jp"])
}
local language = Value(data[userLocale] and userLocale or sourceLocale)
if translator then
	translator:GetPropertyChangedSignal("LocaleId"):Connect(function()
		userLocale = translator.LocaleId
		language:set(data[userLocale] and userLocale or sourceLocale)
	end)
end

export type values = { [string | number]: any }
function translate(id: string, language: string, values: values)
	local text = data[language][id] or data[sourceLocale][id]
	if not text then
		return id
	end
	
	text = string.gsub(text, "{(.-)}", function(key)
		local split = string.split(key, ".")
		if #split == 0 then
			return values[tonumber(key) or key]
		else
			local success, value = xpcall(function()
				local cur = values
				for _,key in split do
					cur = cur[tonumber(key) or key]
				end
				return cur :: any
			end, warn)
			return success and value or "[PARSE_ERROR]"
		end
	end)
	
	return text
end

local fusionCache: { [string]: Fusion.StateObject<string> } = {}
function translateFusion(id: string, values: values?): Fusion.StateObject<string>
	if not values then
		local cached = fusionCache[id]
		if cached then
			return cached
		end
	end
	
	local object = Computed(function()
		return translate(id, language:get(), values or {})
	end)
	if not values then
		fusionCache[id] = object
	end
	
	return object
end

return function()
	return translateFusion, translate, language
end