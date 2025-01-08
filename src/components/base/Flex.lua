
---@alias Zingle.Components.FlexProps.Justify "start"|"end"|"center"|"expand"|"space-around"|"space-between"
---@alias Zingle.Components.FlexProps LuaX.PropsWithChildren<Zingle.Components.helper.Mouseable<{ direction?: "vertical"|"horizontal", reverse?: boolean, gap?: number, justify?: Zingle.Components.FlexProps.Justify }>>

return require("src.components.helper.loader").get("Flex")