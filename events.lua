local modal_notify = require("util.modal_notify")

-- TODO move this function somewhere else
-- Changing layouts results in a graphical notification
tag.connect_signal("property::layout", function(t)
    modal_notify(
        "Tag " .. t.name,
        "Layout changed to " .. t.layout.name
    )
end)
