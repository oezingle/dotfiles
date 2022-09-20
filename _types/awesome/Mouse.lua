---@meta

---@class GeometryWithWidget : Geometry
---@field widget table

---@class CoordinatesWithButtons : Coordinates 
---@field buttons table

---@class Mouse
---@field current_widget_geometries GeometryWithWidget[]|nil
---@field current_widget_geometry GeometryWithWidget|nil
---@field coords fun(): CoordinatesWithButtons
---@field current_wibox table