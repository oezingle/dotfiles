
local get_gtk_menu = require("appmenu.gtk")
local get_canonical_menu = require("appmenu.canonical")

local function get_menu(window_id, callback)
    -- Try GTK
    get_gtk_menu(window_id, function(gtk_menu)
        if gtk_menu then
            callback(gtk_menu)
        else
            get_canonical_menu(window_id, callback)
        end
    end)
end

return get_menu