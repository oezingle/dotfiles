
---@alias Zingle.Components.helper.ClickHandler fun(event: Zingle.Components.helper.MouseClickEvent)

---@alias Zingle.Components.helper.ScrollHandler fun(event: Zingle.Components.helper.MouseWheelEvent)

---@alias Zingle.Components.helper.HoverHandler fun()

---@alias Zingle.Components.helper.Mouseable<T> T | 
---| { ["onclick"|"onrelease"]?: Zingle.Components.helper.ClickHandler, onscroll?: Zingle.Components.helper.ScrollHandler, ["onhover"|"onleave"]?: Zingle.Components.helper.HoverHandler }
