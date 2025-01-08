
---@alias Zingle.Components.GridProps LuaX.PropsWithChildren<Zingle.Components.helper.Mouseable<{ rows: integer, columns: integer, homogeneous?: boolean, expand?: boolean, gap?: integer }>>
---@alias Zingle.Components.Grid LuaX.Component<Zingle.Components.GridProps>

return require("src.components.helper.loader").get("Grid")