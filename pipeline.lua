local frame         = require 'graphics.gui.frame'
local text          = require 'graphics.gui.text'
local context       = require 'graphics.context'
local world         = require 'common.world'
local geometrypass  = require 'graphics.geometrypass'
local lightpass     = require 'graphics.lightpass'
local guipass       = require 'graphics.guipass'
local stage         = require 'graphics.stage'
local outpass       = require 'graphics.outpass'
local texture       = require 'graphics.texture'
local image         = require 'asset.image'
local skyboxpass    = require 'graphics.skyboxpass'
local transpass     = require 'graphics.transparencypass'

return function(args)
    local c = args[1] or error "First element in args table must be context"
    local pipe = {}
    if args.skybox then -- skybox pass
        local skybox = texture()
        skybox:setContext(c)
        if type(args.skybox) == "string" then 
            local test_img = image.loadfile(args.skybox)
            skybox:cubemap("color0", {test_img, test_img, test_img, test_img, test_img, test_img})
        elseif type(args.skybox) == "table" then
            local imgs = {}
            for i, v in ipairs(args.skybox) do
                imgs[i] = image.loadfile(v)
            end
            skybox:cubemap("color0", imgs)
        else
            error("Expected string or table")
        end
        local s = stage()
        s.context = c
        skyboxpass(s, skybox)
        pipe[#pipe+1] = s
    end
    if args.geom then
        local s = stage()
        s.context = c
        geometrypass(s)
        pipe[#pipe+1] = s
    end
    if args.lights then
        pipe[#pipe+1] = lightpass(c)
    end
    if args.transparency then
        local s = stage()
        s.context = c
        transpass(s)
        pipe[#pipe+1] = s
    end
    local root
    if args.gui then
        local s = guipass(c)
        root = frame()
        s:setRoot(root)
        pipe[#pipe+1] = s
    end
    if args.out then
        pipe[#pipe+1] = outpass(c)
    end
    return pipe, root
end

