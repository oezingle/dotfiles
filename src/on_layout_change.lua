local modal_notify = require("src.util.modal_notify")

-- Changing layouts results in a graphical notification
tag.connect_signal("property::layout", function(t)
    modal_notify(
        "Tag " .. t.name,
        "Layout changed to " .. t.layout.name
    )
end)
