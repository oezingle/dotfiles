local LuaX           = require("lib.LuaX")
local create_element = LuaX.create_element
local use_state      = LuaX.use_state
local use_effect     = LuaX.use_effect
local use_context    = LuaX.use_context
local GridContext    = require("src.components.provider.awesome.helper.GridContext")


local max = math.max

--  wibox.layout.grid:get_widgets_at (row, col[, row_span=1[, col_span=1]])
--  wibox.layout.grid:add_widget_at (child, row, col[, row_span=1[, col_span=1]])
--  wibox.layout.grid:get_next_empty ([hint_row=1[, hint_column=1]])


---@param parent table | Awesome.Wibox.Widget
---@param row integer?
---@param column integer?
---@param width integer?
---@param height integer?
---@return { [1]: integer, [2]: integer }?
local function find_space_of_size(parent, row, column, width, height)
    local rows, columns = parent:get_dimension()
    rows = max(rows, parent:get_forced_num_rows())
    columns = max(columns, parent:get_forced_num_cols())

    ---@type integer, integer
    local r_start, r_end = 1, rows
    if row then
        r_start = row
        r_end = row
    end

    ---@type integer, integer
    local c_start, c_end = 1, columns
    if column then
        c_start = column
        c_end = column
    end

    for r = r_start, r_end do
        for c = c_start, c_end do
            local widgets_in_space = parent:get_widgets_at(r, c, height, width)

            if widgets_in_space == nil then
                return { r, c }
            end
        end
    end

    return nil
end

local GridItem = LuaX(function(props)
    local widget, set_widget = use_state()

    local parent = use_context(GridContext)

    use_effect(function()
        if not parent or not widget then
            return
        end

        parent:remove(widget)

        -- ignore: entirely default options. Declarative layout helps us out with this.
        if props.row == props.column == props.width == props.height == nil then
            return
        end

        local width = props.width or 1
        local height = props.height or 1

        local coords = find_space_of_size(parent, props.row, props.column, width, height)

        -- TODO FIXME maybe just silently fail here?
        assert(coords, "Unable to place GridItem")

        ---@type integer, integer
        local row, column = table.unpack(coords)

        parent:add_widget_at(widget, row, column, height, width)

        --[[
            row: y, column: x
        ]]

        return function()
            -- remove self from layout
            parent:remove(widget)
        end
    end, { widget, props.row, props.column, props.width, props.height, props.children })

    return create_element("wibox.layout.stack", {
        ["LuaX::onload"] = function(_, widget)
            set_widget(widget)
        end,

        children = props.children
    })
end)

return GridItem
