local gamestate = require 'gamestate'
local camera    = require 'graphics.camera'
local world     = require 'common.world'
local context   = require 'graphics.context'
local matrix    = require 'math.matrix'
local pipeline  = require 'pipeline'
local frame     = require 'graphics.gui.frame'
local text      = require 'graphics.gui.text'
local file      = require 'asset.file'

function init(self, conf)
    print "Initialize main menu"
    self.camera.projection_matrix = matrix.identity.ptr
    local pipe
    pipe, self.root = pipeline {self.context, gui=true, out=true}
    local georgia = file.load 'georgia.ttf'
    do
        local f = frame()
        f.context = self.context
        f:setPosition(100, 100, 0, 0)
        self.root:addChild(f)
        local label = text(self.context, "en", "ltr", "latin", georgia, 14, "hello, world")
        f:label(label, {1,1,1,1}, "left middle")
    end
    return pipe
end

function enter(self, old)
    print "Enter main menu"
end

function leave(self, new)
    print "Leave main menu"
end

return function(ctx)
    return gamestate.new(init, enter, leave, "Main Menu", ctx)
end

