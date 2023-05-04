local spawn = require("src.agnostic.spawn")

local string = string

---@alias DilaogType "volman"|"thunar"|"accessibility"|"colors"|"display"|"keyboard"|"mime"|"mouse"|"notifications"|"power_manager"|"editor"|"appearance"

---@param dialog DilaogType|nil
local function open_manager(dialog)
    if dialog then
        -- https://www.reddit.com/r/xfce/comments/11c8zex/how_am_i_supposed_to_use_the_dialog_option_in/

        ---@type table<DilaogType, string>
        local dialog_table = {
            volman = "thunar-volman-settings",
            thunar = "thunar-settings",
            accessibility = "xfce4-accessibility-settings",
            colors = "xfce4-color-settings", -- TODO signify that this is printer colors?
            display = "xfce-display-settings",
            keyboard = "xfce-keyboard-settings",
            mime = "xfce4-mime-settings",
            mouse = "xfce-mouse-settings",
            notifications = "xfce4-notifyd-config",
            power_manager = "xfce4-power-manager-settings",
            editor = "xfce4-settings-editor",
            appearance = "xfce-ui-settings",
        }
        
        local dialog_string = dialog_table[dialog]

        if not dialog_string then
            error(string.format("Unknown dialog type %s", dialog))
        end

        spawn(string.format("xfce4-settings-manager -d %s", dialog_string))
    else
        spawn("xfce4-settings-manager")
    end
end

return open_manager
