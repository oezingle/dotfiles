#!/usr/bin/lua

if awesome then
    require("gears.debug").print_warning("appmenu/test.lua: run this file from the command line to debug menus")
    
    return
end

local spawn = require("src.agnostic.spawn")
local get_menu = require("src.appmenu.get_menu")

local arg_index = 1

local function recursive_get_children(menu)
    local search_label = arg[arg_index]

    arg_index = arg_index + 1

    if search_label == ":activate" then
        menu:activate()
    else
        menu:get_children(function(children)
            if search_label then
                local found_index = 0

                for i, child in ipairs(children) do
                    if child.label == search_label then
                        found_index = i
                        
                        break
                    end
                end

                if found_index ~= 0 then
                    recursive_get_children(children[found_index])
                else
                    print("Label '" .. search_label .. "' not found")
                end
            else
                print("Menu Children:")
                for _, child in ipairs(children) do
                    print("", child.label)
                end
            end
        end)
    end
end

if arg[1] == "--help" then
    print("appmenu test")

    print("simulate using the global menu items provided by the current window")

    print("usage: lua appmenu/test.lua [item_label...] [:activate]")
else
    spawn("xprop -root _NET_ACTIVE_WINDOW | grep -oP \"0x\\S+\"", function(result)
        local xwindow = tonumber(result)
    
        get_menu(xwindow, function(menu)
            recursive_get_children(menu)
        end)
    end)    
end
