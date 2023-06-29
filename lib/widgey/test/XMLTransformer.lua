local test = require("lib.test")

local class = require("lib.30log")

---@param doc string
local function print_linenumber(doc)
    local line = 1

    doc = doc
        :gsub("([\n\r])", function(match)
            line = line + 1

            return match .. tostring(line) .. " "
        end)
        :gsub("^", "1 ")

    print(doc)
end

-- TODO These mocks are too weak

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

local wibox = require("wibox")

local XMLTransformer = require("lib.widgey.XMLTransformer")

require("lib.widgey.test.components.Vertical")

test.suite("XMLTransformer",
    test.test(function()
        local component = XMLTransformer.find_component(wibox.widget {
            widget = wibox.layout.flex.vertical,
            _name = "vertical",
            _component_index = 1,
            {
                widget = wibox.widget.imagebox,
                _name = "image",
                _component_index = 1
            },
            {
                widget = wibox.container.margin,
                _name = "margin",
                _component_index = 2,
                {
                    widget = wibox.widget.textbox,
                    _name = "text",
                    _component_index = 1,
                    message = "Hello!"
                }
            }
        }, { 1, 2, 1 })

        assert(component.message == "Hello!")
    end, "find_component"),

    test.test(function()
        local doc = XMLTransformer()
            :set_static(true)
            :set_document([[
                <wibox.widget>
                    <wibox.container.margin margins="{5}" onClick="{function () print('click!') end}">
                        <!-- A comment -->
                        <wibox.layout.flex.vertical spacing="{5}" onSignal="{{ { 'button::press', function () print('hi') end } }}">
                            Example of dynamics {get_status_value()}

                            And multiline!
                        </wibox.layout.flex.vertical>
                    </wibox.container.margin>
                </wibox.widget>
            ]])
            :render()

        assert(doc)

        -- print_linenumber(doc)

        local fn, err = load(doc, "XMLTransformer output", nil, setmetatable({ wibox = wibox }, { __index = _G }))

        if fn then
            local widget = fn()

            assert(widget.get_children)

            assert(XMLTransformer.find_component(widget, { 1, 2, 1 }).text)
        else
            error(err)
        end
    end, "Wibox components - static"),
    test.test(function()
        local widget = XMLTransformer()
            :set_document([[
                <wibox.widget>
                    <wibox.container.margin margins="{5}">
                        <!-- A comment -->
                        <wibox.layout.flex.vertical spacing="{5}" onSignal="{{ { 'button::press', function () print('hi') end } }}">
                            Example of dynamics {get_status_value()}

                            And multiline!
                        </wibox.layout.flex.vertical>
                    </wibox.container.margin>
                </wibox.widget>
            ]])
            :render()

        assert(widget)

        assert(widget.get_children)

        assert(XMLTransformer.find_component(widget, { 1, 2, 1 }).text)
        -- todo a bit more shit here??
    end, "Wibox components - dynamic"),

    test.test(function()
        local doc = XMLTransformer()
            :set_static(true)
            :set_document([[
                <wibox.widget>
                    <Vertical>
                        Hello dumbasses
                    </Vertical>
                </wibox.widget>
            ]])
            :render()

        assert(doc)

        print_linenumber(doc)

        local fn, err = load(doc, "XMLTransformer output", nil, setmetatable({ wibox = wibox }, { __index = _G }))

        if fn then
            local widget = fn()

            assert(widget.get_children)

            assert(XMLTransformer.find_component(widget, { 1, 1 }).text)
        else
            error(err)
        end
    end, "XML component - static"),

    test.test(function()
        local doc = XMLTransformer()
            :set_document([[
                <wibox.widget>
                    <Vertical>
                        Hello dumbasses
                    </Vertical>
                </wibox.widget>
            ]])
            :render()

        assert(doc)

        local fn, err = load(doc, "XMLTransformer output", nil, setmetatable({ wibox = wibox }, { __index = _G }))

        if fn then
            local widget = fn()

            assert(widget.get_children)

            assert(XMLTransformer.find_component(widget, { 1, 1 }).text)
        else
            error(err)
        end
    end, "XML component - static")
)
