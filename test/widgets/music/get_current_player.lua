
local get_current_player = require("src.widgets.components.music.get_current_player")

local test = require("lib.test")

-- TODO rework these tests

test.suite("get_current_player", 
    test.test(function ()
        get_current_player(function (player)
            assert(player == nil or #player ~= 0)
        end)
    end)
)