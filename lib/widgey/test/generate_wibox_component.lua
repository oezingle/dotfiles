
local test = require("lib.test")

local generate_wibox_component = require("lib.widgey.components.generate_wibox_component")

test.suite("generate_wibox_component",
    test.test(function () 
        local Component = generate_wibox_component("nil", {
            children = {},
            spacing_widget = nil,
            spacing = 0,
            max_widget_size = nil,
            forced_height = nil,
            forced_width = nil,
            opacity = nil,
            visible = nil
        })

        Component.static = true

        local render = Component({}):render()

        print(render)

        Component.static = false

        Component({}):render()
    end)
)