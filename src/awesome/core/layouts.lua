local configuration = require("src.configuration")

local split = require("src.polyfill.string.split")
local reduce = require("src.polyfill.list.reduce")

local awful = require("awful")

awful.layout.layouts = {}

-- TODO configuration should allow layouts by string or function.
-- TODO maybe just "awful.<name>" -> awful.layout.<name>
-- TODO and "custom.<name>" -> load from config.layout.<name>

local ret = {}

local ignore_fmt = "Ignoring layout %q: %s"

--[[
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.floating,
    -- awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
]]


---@param config Zingle.Awesome.ConfigurationInfo
function ret.on_config_change(config)
    local section = config.wm.layouts

    local layouts = {}

    for _, layout in ipairs(section) do
        ret.parse_layout(layouts, layout)
    end

    log.info(string.format("Loaded %d layouts", #layouts))

    awful.layout.layouts = layouts
end

---@param layouts (string | function)[]
---@param layout string | function
function ret.parse_layout(layouts, layout)
    if type(layout) == "function" then
        table.insert(layouts, layout)
    else
        ret.parse_layout_by_name(layouts, layout)
    end
end

---@param layouts (string | function)[]
---@param layout string
function ret.parse_layout_by_name(layouts, layout)

    local layout_match = layout:match("^awful%.layout%.(%S+)")
    if layout_match then
        local layout_fn = ret.load_awful_layout(layout_match)

        if layout_fn then 
            table.insert(layouts, layout_fn)

            return
        end
    end

    local layout_match = layout:match("^custom%.(%S+)")
    if layout_match then
        local layout_fn = ret.load_custom_layout (layout_match)

        if layout_fn then
            table.insert(layouts,layout_fn)

            return
        end
    end

    log.warn(string.format(ignore_fmt, layout, "Invalid provider string"))
end

---@param layout_match string
function ret.load_awful_layout(layout_match)
    local ok, layout = pcall(reduce, split(layout_match, "%."), function(table, key)
        return table[key]
    end, awful.layout)

    if not ok then
        log.warn(ignore_fmt, layout, "Key does not exist in awful.layout object")

        return
    end

    return layout
end

---@param layout_match string
function ret.load_custom_layout(layout_match)
    -- TODO FIXME load this shit bruh!
end

---@diagnostic disable-next-line:undefined-global
if not _TEST then
    configuration:on_change(ret.on_config_change)
end

return ret
