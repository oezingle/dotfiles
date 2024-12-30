---@param props Zingle.Awesome.Components.DefaultProps<{}>
local function default_props(props)
    return {
        forced_with = props["forced-width"],
        forced_height = props["forced-height"],

        opacity = props.opacity,
        visible = props.visible,

        -- added for wibox.mod.flexbox
        flex_grow = props["flex-grow"]
    }
end

return default_props