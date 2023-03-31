--[[
    Widget stuff

    - module or class based, not functional
        - i don't want to write more widgets, but widget builder classes would be good
    - reloads if
        - client changes AND that client is clicked
        - mouse leaves and re-enters? (thanks to canonical)
    - closes if
        - item activated

    - section dividers are label-less, and child-less.
        - check labels first for speed, as it is VERY unlikely that any item would have a label but no children
        - half/quarter height?
        - no hover effect

    - KEYBOARD control
        - no navigation code should be linked to signal callbacks

    - keep menu in memory as much as possible
        - limits DBus calls, therefore increasing speed
]]
local appmenu        = require("src.appmenu.appmenu")
local fake_menu_item = require("src.appmenu.menu_provider.fake")

local uppercase_first_letters = require("src.util.uppercase_first_letters")

local menu_builder   = require("src.appmenu.widget.menu")
local button_builder = require("src.appmenu.widget.button")

button_builder.set_menu_builder(menu_builder)
menu_builder.set_button_builder(button_builder)

-- TODO multihead?
---@param callback fun(tag: Tag): any
local function for_every_tag(callback)
    local tags = root.tags()

    local rets = {}

    for index, tag in ipairs(tags) do
        rets[index] = callback(tag)
    end

    return rets
end

---@param client Client|nil
---@param menu MenuBuilder
local function set_menu_client(menu, client)
    if appmenu.set_client(client) then
        if not client then
            menu:set_menu_item(nil)

            return
        end

        appmenu.get()
            :after(function(menu_item)
                local fake = fake_menu_item("dummy")
                    :set_children({
                        fake_menu_item(string.format("<b>%s</b>",
                            uppercase_first_letters(client.class:gsub("-", " "))))
                            :set_children({
                                fake_menu_item("Minimize", function()
                                    client.minimized = true
                                end),

                                ---@param self FakeMenuItem
                                fake_menu_item(client.maximized and "Unmaximize" or "Maximize", function(self)
                                    client.maximized = not client.maximized

                                    self:set_label(client.maximized and "Unmaximize" or "Maximize")
                                end),
                                fake_menu_item("Move to Tag")
                                    :set_children(for_every_tag(function(tag)
                                        return fake_menu_item(tag.name, function()
                                            client:move_to_tag(tag)
                                        end)
                                    end)),
                                fake_menu_item("Sticky", function()
                                    client.sticky = not client.sticky
                                end),
                                fake_menu_item("Quit", function()
                                    client:kill()
                                end),
                                -- fake_menu_item("Appmenu V2")
                            })
                    })

                if menu_item then
                    fake:inherit_children(menu_item)
                end

                menu:set_menu_item(fake)
            end)
            :catch(function(err)
                print(debug.traceback(err))
            end)
    end
end

---@param config AppmenuConfig?
local function create_appmenu(config)
    if config then
        appmenu.set_config(config)
    end

    local menu = menu_builder()
        :set_layout_table({
            [0] = {
                layout = "horizontal",
                popup_direction = "bottom",
                click_focus = true
            },
            default = {
                layout = "vertical",
                popup_direction = "right"
            }
        })
        :set_popup_direction("bottom")
        :set_layout("horizontal")

    -- Shit fix for canonical reloads.
    -- appmenu should store its chosen provider and
    -- then be able to call appmenu.reload_provider()
    -- which calls provider.reload() if it exists
    -- TODO consider provider.on_activate()?
    menu.widget:connect_signal("menu_item::child::activated", function()
        local client = appmenu.client

        menu:set_menu_item(nil)

        if client then
            client:emit_signal("focus")
        end
    end)

    ---@param client Client
    client.connect_signal("button::press", function(client)
        set_menu_client(menu, client)
    end)

    ---@param client Client
    client.connect_signal("unfocus", function(client)
        if not client:isvisible() and appmenu.get_client() == client then
            set_menu_client(menu, nil)
        end
    end)

    ---@param client Client
    client.connect_signal("unmanage", function(client)
        if appmenu.get_client() == client then
            set_menu_client(menu, nil)
        end
    end)

    ---@param client Client
    client.connect_signal("focus", function(client)
        if not appmenu.get_client() then
            set_menu_client(menu, client)
        end
    end)

    return menu:get_widget()
end

return create_appmenu
