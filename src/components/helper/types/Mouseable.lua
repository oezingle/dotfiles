
---@alias Zingle.Awesome.Components.helper.ClickHandler fun(event: Zingle.Awesome.Components.helper.MouseClickEvent)

---@alias Zingle.Awesome.Components.helper.ScrollHandler fun(event: Zingle.Awesome.Components.helper.MouseWheelEvent)

---@alias Zingle.Awesome.Components.helper.HoverHandler fun()

---@alias Zingle.Awesome.Components.helper.Mouseable<T> T | 
---| { ["onclick"|"onrelease"]?: Zingle.Awesome.Components.helper.ClickHandler, onscroll?: Zingle.Awesome.Components.helper.ScrollHandler, ["onhover"|"onleave"]?: Zingle.Awesome.Components.helper.HoverHandler }
