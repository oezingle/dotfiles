-- TODO FIXME nearly all components need to implement 
-- - signal::button::press etc
--    - onclick
--    - onrelease
--    - onhover 
--    - onunhover
-- - forced width/height
-- - opacity / visibility flags (maybe merge into one - opacity = -1.0, 0.0..1.0, visible = opacity == -1.0)
--    - that is, if opacity and visibility even do different things in any case!

require("src.components.helper.mouse.MouseClickEvent")

--- TODO is this ClickHandler generic enough?
---@alias Zingle.Awesome.Components.ClickHandler fun(event: Zingle.Awesome.Components.MouseClickEvent)
---@alias Zingle.Awesome.Components.ScrollHandler fun(event: Zingle.Awesome.Components.MouseWheelEvent)
---@alias Zingle.Awesome.Components.HoverHandler fun()
---@alias Zingle.Awesome.Components.Mouseable<T> T | 
---| { ["onclick"|"onrelease"]?: Zingle.Awesome.Components.ClickHandler, onscroll?: Zingle.Awesome.Components.ScrollHandler, ["onhover"|"onleave"]?: Zingle.Awesome.Components.HoverHandler }

return require("src.components.helper.loader")