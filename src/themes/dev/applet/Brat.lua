local LuaX = require("lib.LuaX")
local use_context = require("lib.LuaX.hooks.use_context")

local ScreenContext = require("src.awesome.ui.ScreenContext")
local Wibox = require("src.components.awesome.Wibox")
local Center = require("src.components.Center")
local Text = require("src.components.Text")

local Brat = LuaX(function()
    local screen = use_context(ScreenContext)

    -- TODO FIXME whitespace isn't removed if brat is on newline
    return [[
        <Wibox name="brat" screen={screen} x={50} y={50} width={200} height={200} color="#89CC04">
            <Center>
                <Text font="Arial" size={24} color="#000000">brat</Text>
            </Center>
        </Wibox>
    ]]
end)

return Brat