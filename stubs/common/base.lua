local base = {}
local per_class = {}

local function metafun(name, def)
    return function(t, ...)
        local tname = t.type.name --ffi.string(t.type.name)
        local pc = per_class[tname]
        if pc and pc[name] then
            local res = pc[name](t, ...)
            if res then return res end
        end
        if def then
            return def(t, ...)
        end
    end
end

local metatypes = {"__call", "__le", "__lt", "__eq", "__len", "__concat", "__unm", "__pow", "__mod", "__div", "__mul", "__sub", "__add"}
local base_mt = {
    __index = metafun("__index", function(t,k) return base.get(t.storage, k) or base[k] end),
    __newindex = metafun("__newindex", function(t,k,v) base.set(t.storage, k, v) end)
}
for _, v in pairs(metatypes) do
    base_mt[v] = metafun(v)
end

local type_mt = {
    __call = function(t)
        return t.create(t)
    end,
    __index = function(t,k)
        return t.storage:get(k) or base[k]
    end,
    __newindex = function(t,k,v)
        t.storage:set(k,v)
    end
}

local storage_mt = {
    __index = function(t,k) return base.get(t,k) or base[k] end,
    __newindex = base.set
}

function base.type(name)
    return function(cons)
        per_class[name] = cons
        local T = {}
        T.name = name
        T.storage = {_table = {}}
        T.create = function(T)
            local v = {}
            v.type = T
            v.storage = {_table = {}}
            v.destructor = function(v)
                if cons.destructor then
                    cons.destructor(v)
                end
            end
            if cons.constructor then
                cons.constructor(v)
            end
            setmetatable(v, base_mt)
            return v
        end
        setmetatable(T, type_mt)
        return T
    end
end

function base.typeof(v)
    return v.type
end

function base.create(t)
    t:create()
end

function base.get(v, name)
    return v._table[name]
end

function base.set(v, name, val)
    v._table[name] = val
end

setmetatable(base, {__call=function(self,...) return base.create(...) end})

return base

