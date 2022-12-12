local fs = require("src.util.fs")

local json = require("lib.json")

-- Ideally change this to # + 6 * char somehow
---@alias HexColor string

---@class WalSpecial
---@field background HexColor
---@field foreground HexColor
---@field cursor HexColor

---@class WalColors
---@field color0 HexColor
---@field color1 HexColor
---@field color2 HexColor
---@field color3 HexColor
---@field color4 HexColor
---@field color5 HexColor
---@field color6 HexColor
---@field color7 HexColor
---@field color8 HexColor
---@field color9 HexColor
---@field color10 HexColor
---@field color11 HexColor
---@field color12 HexColor
---@field color13 HexColor
---@field color14 HexColor
---@field color15 HexColor

---@class Wal
---@field wallpaper string path to pywal's current wallpaper
---@field alpha string alpha as 0-100 percentage NOTE: is a string!
---@field special WalSpecial
---@field colors WalColors

---Get the current pywal color scheme
---@return Wal|nil
local function wal()
    local contents = fs.read(os.getenv("HOME") .. "/.cache/wal/colors.json")

    if contents then
        return json.decode(contents)
    end
end

return wal
