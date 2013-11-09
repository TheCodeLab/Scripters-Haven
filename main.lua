local config    = require 'config'
local setup     = require 'setup'
local mainmenu  = require 'mainmenu'

local conf, err = config.load("sh.conf")
if not conf then
    error("sh.conf: "..err)
end

local ctx = setup((conf.window or {}).width, (conf.window or {}).height)

mainmenu(ctx):start(conf)

ctx:setActive()

