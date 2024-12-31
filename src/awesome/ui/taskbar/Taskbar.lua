
local LuaX = require("lib.LuaX")
local Text = require("src.components.base.Text")
local Margin = require("src.components.base.Margin")
local Background = require("src.components.base.Background")
local Systray = require("src.components").Systray

-- TODO pull from theme

local Taskbar = LuaX(function ()
    local function exit_de ()
        awesome.quit(0)
    end
    
    return [[
        <Background
            color="#ff0000"
        >
            <Margin x={5}>
                <wibox.layout.align.horizontal>
                    <Text font="Arial" size={12} onclick={exit_de}>
                        Exit awesome
                    </Text>

                    <Text font="Arial" size={12}>
                        I am a generic component!
                    </Text>

                    <Systray direction="left" />
                </wibox.layout.align.horizontal>
            </Margin>
        </Background>
    ]]
end)

return Taskbar