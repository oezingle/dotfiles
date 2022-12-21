local awful      = require("awful")
local wibox      = require("wibox")
local Class      = require("src.util.Class")
local gtable     = require("gears.table")
local base       = require("wibox.widget.base")
local no_scroll  = require("src.widgets.helper.no_scroll")
local shapes     = require("src.util.shapes")
local config     = require("config")
local config_dir = require("gears.filesystem").get_configuration_dir()
local get_preferred_size = require("src.widgets.helper.get_preferred_size")

local pack = require("src.agnostic.version.pack")

-- small layout that fits a widget very badly so that it's centered
local center_badly = Class({})

function center_badly:fit(context, width, height)
    return base.fit_widget(self, context, self._private.widget, width, height);
end

function center_badly:layout(_, width, height)
    return { base.place_widget_at(self._private.widget, -width / 2, -height / 2, width, height) }
end

function center_badly:set_children(...)
    local children = pack(...)

    assert(#children == 1)

    self._private.widget = children[1]
end

function center_badly:init(widget)
    local ret = base.make_widget(nil, nil, { enable_properties = true })

    gtable.crush(ret, center_badly, true)

    if widget then
        ret:set_children(widget)
    end

    return ret
end

--------------------------------------------------

--- Calculate the distance between two points
---@param a Coordinates
---@param b Coordinates
---@return number
local function dist2d(a, b)
    return math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2)
end

-- create the instance of the menu
local function create_radial_menu()
    local radial = wibox.layout.manual()

    local box = wibox {
        widget = radial,

        ontop = true,

        bg = "#00000066",

        x      = 0,
        y      = 0,
        width  = 1024,
        height = 1024,
    }

    return box, radial
end

local radial_menu_wibox, radial_menu = create_radial_menu()

--- Set the contents of the radial menu and show it
---@param children { widget: table, callback: function }[] the list of items in the menu
---@param use_mouse boolean? if the mouse coordinates should be the menu's center
local function radial_menu_contents(children, use_mouse)
    children = children or {}

    use_mouse = use_mouse or false

    local s = awful.screen.focused()

    radial_menu_wibox.screen = s

    radial_menu_wibox.width  = s.geometry.width
    radial_menu_wibox.height = s.geometry.height

    local keygrabber

    local function hide_menu(keygrabber_self)
        local keygrabber = keygrabber_self or keygrabber

        radial_menu_wibox.visible = false

        keygrabber:stop()

        mousegrabber.stop()

        radial_menu.children = {}
    end

    keygrabber = awful.keygrabber {
        keybindings = {
            { {}, 'Escape', function(self)
                hide_menu(self)
            end }
        },

        autostart = true,
    }

    radial_menu.children = {}

    local step = (2 * math.pi) / #children

    local circumference = 0

    for _, child in ipairs(children) do
        local width, height = get_preferred_size(child.widget)

        circumference = circumference + math.sqrt(width ^ 2 + height ^ 2)
    end

    local arm_length = math.max(130, circumference / (2 * math.pi))

    local center_x, center_y

    if use_mouse then
        local coords = mouse.coords()

        center_x = coords.x
        center_y = coords.y
    else
        center_x = s.geometry.width / 2
        center_y = s.geometry.height / 2
    end

    local symbolic_children = {}

    -- create a symbolic child widget - points to the parent so that the radial menu can infer the closest button
    local function create_symbolic_child(parent, coordinates)
        -- be close to mouse, supports wrapped_child
        local symbolic_child = wibox.widget {
            layout = wibox.container.margin,

            margins = arm_length,
        }

        -- pass through events
        for _, signal in ipairs({
            "mouse::enter",
            "mouse::leave",
            "button::press"
        }) do
            symbolic_child:connect_signal(signal, function(...)
                parent:emit_signal(signal, ...)
            end)
        end

        -- just kinda center it silently
        coordinates.x = coordinates.x - arm_length
        coordinates.y = coordinates.y - arm_length

        radial_menu:add_at(symbolic_child, coordinates)

        table.insert(symbolic_children, symbolic_child)
    end

    for index, child in ipairs(children) do
        local rad = index * step - (math.pi / 2)

        local x = math.cos(rad) * arm_length + center_x
        local y = math.sin(rad) * arm_length + center_y

        local wrapped_child = wibox.widget {
            {
                child.widget,

                layout = wibox.container.margin,
                margins = 0,
            },
            layout = wibox.container.background,

            shape_border_color = config.popup.fg,

            shape = child.widget.shape or shapes.rounded_rect(100)
        }

        wrapped_child:connect_signal("mouse::enter", function(w)
            child.widget:emit_signal("mouse::enter")

            w.shape_border_width = 3
            w.children[1].margins = 3
        end)

        wrapped_child:connect_signal("mouse::leave", function(w)
            child.widget:emit_signal("mouse::leave")

            w.shape_border_width = 0
            w.children[1].margins = 0
        end)

        wrapped_child:connect_signal("button::press", no_scroll(function()
            child.callback()

            hide_menu()
        end))

        radial_menu:add_at(center_badly(wrapped_child), {
            x = x,
            y = y
        })

        do
            local x = math.cos(rad) * 32 + center_x
            local y = math.sin(rad) * 32 + center_y

            create_symbolic_child(wrapped_child, { x = x, y = y })
        end

    end

    do
        -- central exit button
        local exit_button = wibox.widget {
            {
                {
                    {
                        widget = wibox.widget.imagebox,
                        image = config_dir .. "icon/close-outline.svg",

                        forced_height = 32,
                        forced_width = 32,
                    },
                    layout = wibox.container.place,

                    forced_width = 64,
                    forced_height = 64,
                },

                layout = wibox.container.margin,
                margins = 0
            },
            layout = wibox.container.background,

            shape_border_color = config.popup.fg,

            shape = shapes.rounded_rect(100)
        }

        exit_button:connect_signal("mouse::enter", function(w)
            w.bg = "#ff6666"

            w.shape_border_width = 3
            w.children[1].margins = 3
        end)

        exit_button:connect_signal("mouse::leave", function(w)
            w.bg = config.button.normal

            w.shape_border_width = 0
            w.children[1].margins = 0
        end)

        exit_button:connect_signal("button::press", no_scroll(function()
            hide_menu()
        end))

        exit_button:emit_signal("mouse::enter")

        radial_menu:add_at(center_badly(exit_button), {
            x = center_x,
            y = center_y
        })

        create_symbolic_child(exit_button, { x = center_x, y = center_y })
    end

    --- point to the closest menu item
    mousegrabber.run(
        function ()
            local coords = mouse.coords()
    
            if mouse.current_widget_geometries then
                local closest_child
                local closest_child_dist = 32767
    
                for _, geometry in ipairs(mouse.current_widget_geometries) do
                    local is_symbolic_child = (function()
                        for _, symbolic_child in ipairs(symbolic_children) do
                            if geometry.widget == symbolic_child then
                                return true
                            end
                        end
    
                        return false
                    end)()
    
                    if is_symbolic_child then
                        local center_x = geometry.x + (geometry.width / 2)
                        local center_y = geometry.y + (geometry.height / 2)
    
                        local dist = dist2d(coords, {
                            x = center_x,
                            y = center_y
                        })
    
                        geometry.widget:emit_signal("mouse::leave")
    
                        -- TODO doesn't quite work properly?
                        if dist < closest_child_dist then
                            closest_child = geometry.widget
    
                            closest_child_dist = dist
                        end
                    end
                end
    
                if closest_child then
                    closest_child:emit_signal("mouse::enter")
    
                    local buttons = coords.buttons
    
                    if buttons[1] then
                        closest_child:emit_signal("button::press", 1)
    
                        hide_menu()
    
                        return false
                    end
                end
            end
    
            return true
        end,
        -- TODO better cursor
        "hand1"
    )

    radial_menu_wibox.visible = true
end

return radial_menu_contents
