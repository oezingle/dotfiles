local wibox        = require("wibox")
local WiboxElement = require("lib.LuaX.util.NativeElement.WiboxElement")
local nil_coalesce = require("src.polyfill.nil_coalesce")

local use_effect   = require("lib.LuaX.hooks.use_effect")
local use_memo     = require("lib.LuaX.hooks.use_memo")

-- TODO destroy wibox on unrender (use_effect) and audit props for dynamicism

---@alias Zingle.Awesome.Components.Wibox.Props LuaX.Props.WithInternal<LuaX.PropsWithChildren<{ name: string, screen: Awesome.Screen, color?: string, ["x"|"y"|"width"|"height"]: number, ["visible"|"ontop"]?: boolean }>>
local function Wibox(props)
    local name = props.name
    local screen = props.screen

    -- TODO kinda unneccessary?
    assert(name, "Wibox must have a unique name")
    assert(screen, "Wibox must be attached to a screen")

    assert(props.x and props.y and props.width and props.height, "Wibox must have x, y, width, and height")
    local w = use_memo(function()
        log.debug("Creating wibox")

        return wibox {
            widget = wibox.widget {
                widget = wibox.layout.stack,
            },

            screen = screen,

            visible = false,

            ontop = nil_coalesce(props.ontop, true),
        }
    end, {})

    use_effect(function()
        w.visible = nil_coalesce(props.visible, true)
    end, { w, props.visible })

    use_effect(function()
        w.width = props.width
        w.height = props.height

        w.x = props.x
        w.y = props.y
    end, { w, props.width, props.height, props.x, props.y })

    use_effect(function()
        w.bg = props.color
    end, { w, props.color })

    ---@type LuaX.NativeElement
    local root = use_memo(function ()
        return WiboxElement.get_root(w.widget)
    end, { w.widget })

    use_effect(function()
        local renderer = props.__luax_internal.renderer

        if w.visible then
            local ok, err = pcall(function()
                renderer:render(props.children[1], root)
            end)

            if not ok then
                error(string.format("In Wibox %q", name) .. err)
            end
        end
    end, { root, w, props.children })

    return nil
end

-- From LuaX:
--[[
    ---@param props LuaX.Props.WithInternal<LuaX.PropsWithChildren<{ width: number, height: number, x: number, y: number, bg: any }>>
local function Wibox(props)
    -- TODO FIXME wibox doesn't clean itself up.
    -- TODO creates stack overflow (but only sometimes??)
    local w = use_memo(function()
        print("Creating wibox")

        return wibox({
            visible = true
        })
    end, {})

    use_effect(function()
        w.width = props.width
        w.height = props.height

        w.x = props.x
        w.y = props.y
    end, { props.width, props.height, props.x, props.y })

    use_effect(function ()
        w.bg = props.bg
    end, { props.bg })

    use_effect(function()
        local renderer = props.__luax_internal.renderer

        local root_widget = wibox.widget {
            layout = wibox.layout.stack
        }
        w.widget = root_widget

        ---@type LuaX.NativeElement
        local root = WiboxElement.get_root(root_widget)

        renderer:render(props.children, root)
    end, { props.children })

    return nil
end
]]

return Wibox
