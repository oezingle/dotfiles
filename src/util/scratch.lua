local awful = require("awful")

local config = require("config")

-- TODO chromium apps are no bueno
--- Run any command as a scratch - floating, discarded upon unfocus
---@param command string
---@param keep_on_unfocus boolean? whether or not to keep the window on unfocus. default false
local function spawn_scratch(command, keep_on_unfocus)
    keep_on_unfocus = keep_on_unfocus or false

    local s = awful.screen.focused()

    -- the fractional size of the screen the scratch terminal should take up
    -- TODO better way to configure this
    local fraction_v = 3 / 4
    local fraction_h = 2 / 3

    ---@type number
    local s_width = s.geometry.width
    ---@type number
    local s_height = s.geometry.height

    awful.spawn(command, {
        floating          = true,
        ontop             = not keep_on_unfocus and true,
        titlebars_enabled = false,
        skip_taskbar      = not keep_on_unfocus and true,
        urgent            = true,
        width             = s_width * fraction_h,
        height            = s_height * fraction_v,
        x                 = (s_width - s_width * fraction_h) / 2, -- placement didn't work :(
        y                 = (s_height - s_height * fraction_v) / 2,
        callback          = function(c)
            if not keep_on_unfocus then
                for _, signal in ipairs({ "unfocus", "mouse::leave" }) do
                    c:connect_signal(signal, function()
                        if c then
                            c:kill()
                        end
                    end)
                end
            end
        end
    })
end

--- Create a scratch terminal that gets discarded upon unfocus
---@param command string
---@param keep_on_unfocus boolean? whether or not to keep the window on unfocus. default false
local function scratch_terminal(command, keep_on_unfocus)
    local cmd_flag = command and (" -e \"" .. command .. "\"") or ""

    spawn_scratch(config.apps.terminal .. cmd_flag, keep_on_unfocus)
end

local scratch = {
    spawn = spawn_scratch,
    terminal = scratch_terminal
}

for key, fn in pairs(scratch) do
    awesome.connect_signal("scratch::" .. key, fn)
end

setmetatable(scratch, {
    __call = function(_, ...)
        scratch.spawn(...)
    end
})

return scratch
