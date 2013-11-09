local context       = require 'graphics.context'

return function(width, height)
    local c = context()
    -- hints here
    c:build()
    c:resize(width or 800, height or 600, "Scripter's Haven")
    return c
end

