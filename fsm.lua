local fsm = {}

function fsm.new(init, enter, leave, name)
    assert(type(init) == 'function')
    assert(type(enter) == 'function')
    assert(type(leave) == 'function')
    assert(type(name) == 'string')
    local t
    t = {
        init = function(...) 
            t.first = false; 
            if init then 
                init(...) 
            end 
        end, 
        enter = enter, 
        leave = leave, 
        first = true, 
        active = false, 
        name = name or "Unnamed"
    }
    setmetatable(t, {__index=fsm})
    return t
end

function fsm:copy()
    local t = {
        init = self.init,
        enter = self.enter,
        leave = self.leave,
        first = true,
        active = false,
        name = self.name
    }
    setmetatable(t, {__index=fsm})
    return t
end

function fsm:trysetup(...)
    if self.first then
        self:init(...)
    end
    return self
end

function fsm:start(...)
    self.active = true
    return self:trysetup(...):enter()
end

function fsm:transition(new)
    self:leave(new)
    self.active = false
    new.active = true
    new:trysetup():enter(self)
    return new
end

return fsm

