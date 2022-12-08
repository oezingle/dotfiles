local awful = require("awful")

--- Create a function that updates the text of a given widget using a command
---@param command string the command to run
---@param if_empty string? the text if the command returns nothing
---@param max_length number? length to shorten the returned string to
---@return fun(widget: table): nil
local function cmd_widget_generator(command, if_empty, max_length)
    max_length = max_length or 1000

    return function(widget)
        awful.spawn.easy_async(
            command,
            function(stdout)
                -- cut out last char because playerctl appends a newline.
                -- concat after max_length chars to keep string length predictable (long song titles make things iffy)
                local text = stdout:sub(1, -2)

                if #text > max_length then
                    text = text:sub(1, max_length - 3) .. "..."
                end

                if not text or text == "" then
                    text = if_empty or "Empty String"
                end

                widget.text = text
            end
        )
    end
end

return cmd_widget_generator