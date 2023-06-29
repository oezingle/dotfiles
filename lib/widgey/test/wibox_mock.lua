local class = require("lib.30log")

if not package.loaded["wibox"] then
    local widget = class("Mock.Wibox.Widget")

    function widget:init(w)
        for k, v in pairs(w) do
            self[k] = v
        end

        for i, kid in ipairs(w) do
            self[i] = widget(kid)
        end
    end

    function widget:get_children()
        local kids = {}

        for _, kid in ipairs(self) do
            table.insert(kids, kid)
        end

        return kids
    end

    ---@param name string
    ---@param fn function
    function widget:connect_signal(name, fn)
        -- print(self.widget)
    end

    package.loaded["wibox"] = {
        container = { margin = "wibox.container.margin" },
        layout = {
            flex = { vertical = "wibox.layout.flex.vertical" }
        },
        widget = widget
    }
end