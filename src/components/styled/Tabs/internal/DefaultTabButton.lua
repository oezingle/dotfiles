
local LuaX = require("lib.LuaX")
local use_state = LuaX.use_state

local Background = require("src.components.base.Background")
local Text = require("src.components.base.Text")
local Margin = require("src.components.base.Margin")

--[[
    props:
        selected
        onclick
        text_color
]]

-- TODO if type(props.children) == "string" then automatically create a Text element, but allow any child within DefaulTabButton

-- TODO FIXME stylized button would be nice. This is just the one from Console
local DefaultTabButton = LuaX(function(props)
    local is_hovered, set_hovered = use_state(false)

    local background_color = "#222222"
    local border_color = (props.selected and "#ffffff") or
        (is_hovered and "#AAAAAA" or "#777777")

    return [[
        <Background
            color={background_color}

            border-width={3}
            border-color={border_color}

            onclick={props.onclick}
            onhover={function () set_hovered(true) end}
            onleave={function () set_hovered(false) end}
        >
            <Margin x={3} y={1}>
                <Text size={10} color={props.text_color or "#ffffff"}>{props.children}</Text>
            </Margin>
        </Background>
    ]]
end)

return DefaultTabButton
