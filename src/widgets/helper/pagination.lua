local base   = require("wibox.widget.base")
local gtable = require("gears.table")
local Class  = require("src.util.Class")
local pack = require("src.agnostic.version.pack")

local pagination = Class()

function pagination:set_page(new_page)
    local old_page = self._private.page

    if new_page > #self._private.pages then
        new_page = 1
    elseif new_page < 1 then
        new_page = #self._private.pages
    end

    if old_page ~= new_page then
        self._private.pages[old_page].visible = false
        self._private.pages[old_page]:emit_signal("property::visible")

        self._private.pages[new_page].visible = true
        self._private.pages[new_page]:emit_signal("property::visible")

        self._private.page = new_page

        self:emit_signal("property::page")

        self:emit_signal("widget::layout_changed")
    end
end

function pagination:get_page()
    return self._private.page
end

function pagination:next()
    -- should trigger handlers?
    self.page = self.page + 1
end

function pagination:prev()
    -- should trigger handlers?
    self.page = self.page - 1
end

function pagination:set_children(...)
    -- im high and hehe childs
    local childs = pack(...)

    self._private.pages = childs
end

function pagination:get_children()
    return self._private.pages
end

function pagination:fit(context, width, height)
    local widget = self.children[self.page]

    return base.fit_widget(self, context, widget, width, height)
end

function pagination:layout(_, width, height)
    local widget = self.children[self.page]

    return { base.place_widget_at(widget, 0, 0, width, height) }
end

function pagination:init(children)
    local ret = base.make_widget(nil, nil, { enable_properties = true })

    gtable.crush(ret, pagination, true)

    ret._private.page = 1

    children = children or {}

    ret._private.pages = children

    ret:connect_signal("property::visible", function (p)
        ret.children[ret.page].visible = p.visible

        ret.children[ret.page]:emit_signal("property::visible")
    end)

    return ret
end

return pagination
