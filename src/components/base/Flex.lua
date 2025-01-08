
---@alias Zingle.Awesome.Components.FlexProps.Justify "start"|"end"|"center"|"expand"|"space-around"|"space-between"
---@alias Zingle.Awesome.Components.FlexProps LuaX.PropsWithChildren<Zingle.Awesome.Components.helper.Mouseable<{ direction?: "vertical"|"horizontal", reverse?: boolean, gap?: number, justify?: Zingle.Awesome.Components.FlexProps.Justify }>>

return require("src.components.helper.loader").get("Flex")