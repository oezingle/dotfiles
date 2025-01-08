
---@meta

---@class Zingle.Awesome.Components.helper.MouseEvent 
---@field modifiers table<"shift"|"alt"|"super"|"control", boolean>
---@field relative_pos { x: number, y: number }
---@field vanilla any

---@class Zingle.Awesome.Components.helper.MouseWheelEvent : Zingle.Awesome.Components.helper.MouseEvent
---@field deltax number
---@field deltay number
---@field modifiers Zingle.Awesome.Components.helper.Modifiers

---@class Zingle.Awesome.Components.helper.MouseClickEvent : Zingle.Awesome.Components.helper.MouseEvent
---@field button Zingle.Awesome.Components.helper.MouseButton