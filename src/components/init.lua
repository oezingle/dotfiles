-- TODO FIXME nearly all components need to implement 
-- - signal::button::press etc
--    - onclick
--    - onrelease
--    - onhover 
--    - onunhover
-- - forced width/height
-- - opacity / visibility flags (maybe merge into one - opacity = -1.0, 0.0..1.0, visible = opacity == -1.0)
--    - that is, if opacity and visibility even do different things in any case!

require("src.components.helper.types.MouseButton")
require("src.components.helper.types.Modifiers")

require("src.components.helper.types.MouseEvent")

require("src.components.helper.types.Mouseable")

return require("src.components.helper.loader")