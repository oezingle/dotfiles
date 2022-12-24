
local get_current_player = require("src.widgets.music.get_current_player")

local test = require("lib.test")

test.suite("get_current_player", 
    test.test(function ()
        get_current_player(function (player)
            assert(player == nil or #player ~= 0)
        end)
    end)
)