local fsm = require 'fsm'
local world = require 'common.world'
local camera = require 'graphics.camera'

local gs = {}

function gs.new(init, enter, leave, name, ctx)
    return fsm.new(
        function(self, ...) 
            self.context = ctx
            self.world = world()
            self.camera = camera()
            self.pipe = init(self, ...)
        end,
        function(self, old)
            self.context.world = self.world
            self.context.camera = self.camera
            for i,v in pairs(self.pipe) do 
                self.context:addStage(v, i) 
            end
            enter(self, old)
        end,
        function(self, new)
            self.context:clearStages()
            leave(self, new)
        end,
        name
    )
end

return gs

