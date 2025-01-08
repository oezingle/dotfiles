local LuaX           = require("lib.LuaX")
local create_element = LuaX.create_element
local use_state      = LuaX.use_state

local nil_coalesce   = require("src.polyfill.nil_coalesce")
local list_reverse = require("src.polyfill.list.reverse")

local merge_props    = require("src.components.helper.merge_props")
local mouse_props    = require("src.components.provider.awesome.helper.mouse_props")
local default_props  = require("src.components.provider.awesome.helper.default_props")
local GridContext    = require("src.components.provider.awesome.helper.GridContext")

local Grid           = LuaX(function(props)
    local widget, set_widget = use_state(nil)

    return create_element(GridContext.Provider, {
        value = widget,
        children = create_element("wibox.layout.grid", merge_props({
            forced_num_cols = assert(props.columns, "Grid must have a given column count"),
            forced_num_rows = assert(props.rows, "Grid must have a given row count"),

            spacing = props.gap,

            -- By default, expand homogeneously.
            homogeneous = nil_coalesce(props.homogeneous, true),
            expand = nil_coalesce(props.expand, true),

            -- Stupid bug fix: children choose positions in the inverse order of
            -- their rendering by default, so reverse that and the behaviour
            -- feels normal.
            children = list_reverse(props.children),

            ["LuaX::onload"] = function (_, widget)
                set_widget(widget)
            end
        }, mouse_props.create(props), default_props(props)))

    })
end)

return Grid
