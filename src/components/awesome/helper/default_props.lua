---@param props Zingle.Awesome.Components.DefaultProps<{}>
local function default_props(props)
    return {
        forced_with = props["forced-width"],
        forced_height = props["forced-height"],

        opacity = props.opacity,
        visible = props.visible
    }
end

return default_props