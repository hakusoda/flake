--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local types = require(script:WaitForChild("types"))
local Fusion = require(script:WaitForChild("Fusion"))
export type StateObject<T> = Fusion.StateObject<T>
export type CanBeState<T> = Fusion.CanBeState<T>
export type Symbol = Fusion.Symbol
export type Value<T> = Fusion.Value<T>
export type Computed<T> = Fusion.Computed<T>
export type ForPairs<KO, VO> = Fusion.ForPairs<KO, VO>
export type ForKeys<KI, KO> = Fusion.ForKeys<KI, KO>
export type ForValues<VI, VO> = Fusion.ForKeys<VI, VO>
export type Observer = Fusion.Observer
export type Tween<T> = Fusion.Tween<T>
export type Spring<T> = Fusion.Spring<T>

export type createAddon = <T>(id: string, name: string, version: string) -> (T, (addons: types.addons) -> T)
return function()
	return Fusion, require(ReplicatedStorage:WaitForChild("flakeModule"):WaitForChild("helpers"):WaitForChild("createAddon")) :: createAddon
end