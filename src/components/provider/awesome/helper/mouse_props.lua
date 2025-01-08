local Awesome     = require("lib.awesome_capi")
local MouseButton = require("src.components.helper.types.MouseButton")

local mouse_props = {}

---@param mods string[]
---@return Zingle.Awesome.Components.helper.Modifiers
function mouse_props.modifiers(mods)
    local modifiers = {
        super = false,
        shift = false,
        alt = false,
        control = false,
    }

    for _, mod in ipairs(mods) do
        if mod == "Super" then
            modifiers.super = true
        elseif mod == "Shift" then
            modifiers.shift = true
        elseif mod == "Mod1" then
            modifiers.alt = true
        elseif mod == "Control" then
            modifiers.control = true
        end
    end

    return modifiers
end

function mouse_props.transform_button(button)
    local translations = {
        [Awesome.Mouse.MouseButton.LEFT] = MouseButton.LEFT,
        [Awesome.Mouse.MouseButton.RIGHT] = MouseButton.RIGHT,
        [Awesome.Mouse.MouseButton.MIDDLE] = MouseButton.MIDDLE,
    }

    return translations[button]
end

---@param click Zingle.Awesome.Components.helper.ClickHandler?
---@param scroll Zingle.Awesome.Components.helper.ScrollHandler?
function mouse_props.transform_button_press(click, scroll)
    if not click and not scroll then
        return nil
    end

    return function(widget, lx, ly, button, mods, metadata)
        local vanilla = { widget, lx, ly, button, mods, metadata }

        -- TODO side scroll causes nil button - can i get any more info?
        if button == nil then
            return
        end

        if button == Awesome.Mouse.MouseButton.SCROLL_UP or button == Awesome.Mouse.MouseButton.SCROLL_DOWN then
            if not scroll then
                return
            end

            -- TODO acceleration?
            local deltax = button == Awesome.Mouse.MouseButton.SCROLL_UP and -1 or 1

            scroll({
                deltax       = deltax,
                deltay       = 0,
                relative_pos = { x = lx, y = ly },
                modifiers    = mouse_props.modifiers(mods),
                vanilla      = vanilla
            })
        else
            if not click then
                return
            end

            click({
                button       = mouse_props.transform_button(button),
                relative_pos = { x = lx, y = ly },
                modifiers    = mouse_props.modifiers(mods),
                vanilla      = vanilla
            })
        end
    end
end

---@param props Zingle.Awesome.Components.helper.Mouseable<{}>
---@return LuaX.Props
function mouse_props.create(props)
    local ret = {}

    ret["signal::button::press"] = mouse_props.transform_button_press(props.onclick, props.onscroll)
    ret["signal::button::release"] = mouse_props.transform_button_press(props.onrelease, nil)

    ret["signal::mouse::enter"] = props.onhover
    ret["signal::mouse::leave"] = props.onleave

    return ret
end

return mouse_props
