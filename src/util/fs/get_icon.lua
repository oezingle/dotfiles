
local folder_of_this_file = (...):match("(.-)[^%.]+$")

---@module "src.util.fs.directories"
local dirs = require(folder_of_this_file .. "directories")

--- A quick and dirty function to get an icon's svg path
--- for example apps.svg -> ~/.config/awesome/icon/apps.svg
---@param path string a partial path
local function get_icon(path)
    return dirs.icon .. path
end

return get_icon