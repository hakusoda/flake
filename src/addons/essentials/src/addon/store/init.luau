local Rodux = require(script.Parent.libraries.rodux)
local Reducer = require(script.reducers.Reducer)
return Rodux.Store.new(Reducer, nil, {
    Rodux.thunkMiddleware
} :: any)