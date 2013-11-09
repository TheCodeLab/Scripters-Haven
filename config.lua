local config = {}

function config.load(file)
    if type(file) == 'string' then
        local handle = io.open(file, 'r')
        if not handle then
            config.save(require 'config-defaults', file)
            file = io.open(file, 'r')
        else
            file = handle
        end
    end
    return loadstring("return " .. file:read '*a')()
end

function config.save(conf, file)
    print "hi"
    local serialize 
    serialize = function(t, i, iskey)
        print(tostring(t), i, iskey)
        if type(t) == "table" and iskey then
            error("Not serializable: Table key")
        elseif type(t) == "table" then
            local str = "{\n"
            for k, v in pairs(t) do
                str = string.format("%s%s%s = %s,\n", 
                    str,
                    ("\t"):rep(i+1),
                    serialize(k, 0, true),
                    serialize(v, i+1, false)
                )
            end
            return str .. ("\t"):rep(i) .. "}"
        elseif type(t) == "string" then
            return iskey and string.format("[%q]", t) or string.format("%q", t)
        elseif type(t) == "number" then
            return iskey and string.format("[%d]", t) or tostring(t)
        elseif type(t) == "bool" then
            return iskey and string.format("[%b]", t) or tostring(t)
        end
        error("NYI: "..tostring(t))
    end
    if type(file) == 'string' then
        file = io.open(file, 'w')
    end
    file:write(serialize(conf, 0, false) .. '\n')
    file:flush()
end

return config

