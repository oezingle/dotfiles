local argparse = require("lib.argparse")
local Promise  = require("src.util.Promise")

local spawn    = require("src.agnostic.spawn.promise")
local appmenu  = require("src.appmenu_v2.appmenu")

---@param menu_items MenuItem[]
---@return fun(): MenuItem|nil
local function ichildren(menu_items)
    local i = nil

    local menu_item = nil

    return function()
        i, menu_item = next(menu_items, i)

        if not menu_item then
            return nil
        end

        if not menu_item.label then
            error("Child menu item doesn't have a label")
        end

        local transformed_label = menu_item.label:gsub("_", "")

        menu_item.label = transformed_label

        return menu_item
    end
end

---@param menu MenuItem
---@param path string
---@param activate boolean
local function recursive_menu_finder(menu, path, activate)
    if activate and #path == 0 then
        return menu:activate()
    else
        return menu:get_children()
            :after(function(menu_items)
                if #path > 0 then
                    local wanted_name = path:match("([^%.]+)[%.]?")

                    for menu_item in ichildren(menu_items) do
                        if menu_item.label:gsub(" ", "_") == wanted_name then
                            local new_path = path:gsub("[^%.]+.?", "", 1)

                            return recursive_menu_finder(menu_item, new_path, activate)
                        end
                    end

                    print("No menu item found by path segment " .. wanted_name)
                else
                    print("\nMenu Items:")

                    local next_menu_item = ichildren(menu_items)

                    local function recurse()
                        local menu_item = next_menu_item()

                        if not menu_item then
                            return
                        end

                        menu_item:has_children()
                            :after(function(has_children)
                                local children = has_children and ">" or " "

                                print("", "|" .. menu_item.label, children)
                            end)
                            :after(recurse)
                            :catch(function(err)
                                print("err", err)
                            end)
                    end

                    recurse()
                end
            end)
    end
end

---@param window_id string?
local function get_window(window_id)
    if window_id then
        return Promise.resolve(window_id)
    else
        return spawn("xprop -root _NET_ACTIVE_WINDOW | grep -oP \"0x\\S+\"")
    end
end

local function main()
    local parser = argparse("cli.lua", "A dirty command line to test GTK/Canonical DBus menus")

    parser:option("-p --path", "the menu items to navigate through, using periods as seperators. ie File.Open_Recent", "")
    parser:option("-w --window", "The X window id")
    parser:flag("-a --activate", "Activate the resulting menu item")

    local args = parser:parse()

    get_window(args.window)
        :after(function(xwindow)
            xwindow = xwindow:sub(1, -2)

            print("xwindow", xwindow)

            appmenu.set_client({ window = xwindow })

            appmenu.load_provider()
                :after(function(provider)
                    if provider then
                        print("Appmenu provider", provider.MENU_TYPE)

                        local menu = provider:get_menu()

                        recursive_menu_finder(menu, args.path, args.activate)
                    else
                        print("No appmenu")
                    end
                end)
                :catch(function(err)
                    print("err", err)
                end)
        end)
end

main()
