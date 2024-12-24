
local LuaX = require("lib.LuaX")
local use_context = require("lib.LuaX.hooks.use_context")

local ScreenContext = require("src.awesome.ui.ScreenContext")

local Wibox = require("src.components.awesome.Wibox")
local Text = require("src.components.Text")
local Background = require("src.components.Background")

local use_animated = require("src.hooks.use_animated")

local Animation = LuaX(function ()
    local screen = use_context(ScreenContext)

    local pos, set_target = use_animated(5, 1.0)

    print(pos)

    return [[
        <Wibox name="animation" screen={screen} x={50} y={50} width={200} height={200} color="#ffffff">
            <Background color="#ff0000">
                <wibox.layout.fixed.vertical signal::button::press={function () 
                    print("click!")

                    if (target or 0) > 0.5 then
                        set_target(0.0)     
                    else
                        set_target(1.0)
                    end
                end}>
                    <Text font="Arial" size={24} color="#000000">animation</Text>

                    <Text font="Arial" size={math.floor(pos * 24)} color="#000000">bruh</Text>
                </wibox.layout.fixed.vertical>
            </Background>
        </Wibox>
    ]]
end)

return Animation