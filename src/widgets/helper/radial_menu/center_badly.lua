local Class  = require("src.util.Class")
local gtable = require("gears.table")
local base   = require("wibox.widget.base")
local pack   = require("src.agnostic.version.pack")


-- small layout that fits a widget very badly so that it's centered in the radial menu
local center_badly = Class({})

function center_badly:fit(context, width, height)
    return base.fit_widget(self, context, self._private.widget, width, height);
end

function center_badly:layout(_, width, height)
    return { base.place_widget_at(self._private.widget, -width / 2, -height / 2, width, height) }
end

function center_badly:set_children(...)
    local children = pack(...)

    assert(#children == 1)

    self._private.widget = children[1]
end

function center_badly:init(widget)
    local ret = base.make_widget(nil, nil, { enable_properties = true })

    gtable.crush(ret, center_badly, true)

    if widget then
        ret:set_children(widget)
    end

    return ret
end

return center_badly