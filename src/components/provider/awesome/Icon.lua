local LuaX           = require("lib.LuaX")
local create_element = LuaX.create_element
local dir            = require("src.util.dir")
local join           = require("src.polyfill.path.join")
local fs             = require("src.util.fs")

-- TODO get cached icons from join(dir.generated.icon(), style, name, color .. ".svg")
-- (mkdir -p)

---@param name string
---@param style string
---@param color string?
local function get_icon(name, style, color)
    local generic_path = join(dir.lib.iconoir(), style, name .. ".svg")

    -- TODO how slow is this operation? might have to cache results.
    assert(fs.exists(generic_path))

    if color == nil then
        return generic_path
    end

    -- TODO clear this cache on WM restart.
    local cache_path = join(dir.lib.iconoir(), style, name, color .. ".svg")

    if not fs.exists(cache_path) then
        local icon_content = fs.read(generic_path)
    end

    return cache_path
end

---@param props Zingle.Awesome.Components.IconProps
local Icon = LuaX(function(props)
    assert((not props.color) or type(props.color) == "string", "Icon color must be a string!")

    return create_element("wibox.widget.imagebox", {
        image = get_icon(props.name, props.style or "regular", props.color)
    })
end)

return Icon
