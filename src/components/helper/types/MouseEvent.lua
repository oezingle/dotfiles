
---@meta

---@class Zingle.Components.helper.MouseEvent 
---@field modifiers table<"shift"|"alt"|"super"|"control", boolean>
---@field relative_pos { x: number, y: number }
---@field vanilla any

---@class Zingle.Components.helper.MouseWheelEvent : Zingle.Components.helper.MouseEvent
---@field deltax number
---@field deltay number
---@field modifiers Zingle.Components.helper.Modifiers

---@class Zingle.Components.helper.MouseClickEvent : Zingle.Components.helper.MouseEvent
---@field button Zingle.Components.helper.MouseButton