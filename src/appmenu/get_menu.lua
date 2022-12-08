
local get_gtk_menu = require("src.appmenu.gtk")
local get_canonical_menu = require("src.appmenu.canonical")

local function get_menu(window_id, callback)
    -- Try GTK
    get_gtk_menu(window_id, function(gtk_menu)
        if gtk_menu then
            callback(gtk_menu)
        else
            get_canonical_menu(window_id, function (canonical_menu)
                if canonical_menu then
                    callback(canonical_menu)
                else
                    callback(nil)
                end

                -- there's no menu here at all
            end)
        end
    end)
end

return get_menu