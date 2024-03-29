local fs                 = require("src.util.fs")
local check_dependencies = require("src.sh.check_dependencies")
local spawn              = require("src.agnostic.spawn.promise")
local wallpaper          = require("src.util.wallpaper")
local is_light           = require("src.util.wallpaper.is_light")

local    config = require("config")

local json = require("lib.json")

local setmetatable = setmetatable

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

local has_pywal_installed = false

if config.gimmicks.pywal then
    check_dependencies({ "wal" })
        :after(function()
            has_pywal_installed = true

            awesome.emit_signal("wal::init")
        end)
end

---@class WalReturn
---@operator call:Wal|nil
local ret = setmetatable({
    --- Call a callback when the pywal changes
    ---@param callback fun(scheme: Wal): nil
    on_change = function(callback)
        if not config.gimmicks.pywal then
            return
        end
        local cb = function()
            if has_pywal_installed then
                local scheme = wal()

                if scheme then
                    callback(scheme)
                end
            end
        end

        -- callbacks when pywal is found to be installed
        awesome.connect_signal("wal::init", cb)

        awesome.connect_signal("wal::changed", cb)

        if has_pywal_installed then
            cb()
        end
    end,
    update = function()
        if not config.gimmicks.pywal then
            return
        end

        is_light()
            :after(function(is_light)
                -- l for light mode
                -- n skips wallpaper
                -- t skips tty
                spawn(string.format("wal %s -n -t -i '%s'", is_light and "-l" or "", wallpaper.get_current()))
                    :after(function()
                        awesome.emit_signal("wal::changed")
                    end)
            end)
    end,
}, {
    __call = wal
})

ret.create_hook = function()
    if not config.gimmicks.pywal then
        return
    end

    check_dependencies({ 'wal' })
        :after(function()
            ret.update()

            awesome.connect_signal("wallpaper_should_change", ret.update)
        end)
end


---@operator call:Wal|nil
return ret
