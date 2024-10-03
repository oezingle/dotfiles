
-- TODO check if text is available - without diamond dependency
-- TODO if text component available and this component is missing (eg, not something like systray)
-- TODO then warn!
---@param component string
local function not_available (component)
    return function ()
        log.error(string.format("Component %s cannot be rendered by this component provider", component))

        return nil
    end
end

return not_available