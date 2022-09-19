---@meta

---@alias GeometryWithWidget { x: number, y: number, width: number, height: number, widget: table }

---@alias CoordinatesWithButtons { x: number, y: number, buttons: table }

---@class Mouse
---@field current_widget_geometries GeometryWithWidget[]|nil
---@field coords fun(): CoordinatesWithButtons
---@field current_wibox table