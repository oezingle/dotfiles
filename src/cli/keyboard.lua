---@class CLI.Keyboard
---@field tty string|nil
local keyboard = {
    history = {},
    history_pos = 0,
    cursor = 0,
    line = {},
    tty = nil
}

-- TODO far too many functions exposed to users

-- http://lua-users.org/lists/lua-l/2012-09/msg00360.html
---@param ... string
function keyboard.stty(...)
    local ok, p = pcall(io.popen, "stty -g")

    if not ok or not p then return nil end

    local state = p:read()
    p:close()


    if state and #... then
        os.execute(table.concat({ "stty", ... }, " "))
    end

    return state
end

local stty = keyboard.stty

function keyboard._reset()
    keyboard.history_pos = 0

    keyboard.cursor = 0
end

-- TODO commands should not be commands but rather a callback function taking a line as an argument
--- Run the CLI prompt.
---@param callback fun(command: string): any
function keyboard.prompt(callback)
    keyboard.tty = stty("-echo", "cbreak")

    local ok, err = pcall(keyboard._readlines, callback)

    if not ok then
        -- restore tty state and then re-throw the error
        stty(keyboard.tty)

        error(err)
    end

    stty(keyboard.tty)
end

---@param callback fun(command: string): any
function keyboard.readline(callback)
    keyboard.tty = stty("-echo", "cbreak")

    local ok, err = pcall(keyboard._readline, callback)

    if not ok then
        -- restore tty state and then re-throw the error
        stty(keyboard.tty)

        error(err)
    end

    stty(keyboard.tty)
end

---@param callback fun(command: string): any
function keyboard._readline(callback)
    keyboard._reset()

    keyboard._print_prompt()

    local line = keyboard._read()

    callback(line)

    -- Disallow the same command over and over from cluttering history
    if keyboard.history[1] ~= line then
        table.insert(keyboard.history, 1, line)
    end
end

---@param callback fun(command: string)
function keyboard._readlines(callback)
    while true do
        keyboard._readline(callback)
    end
end

--- clear the line from the cursor position
function keyboard._clear()
    -- move back to start of line
    for _ = 1, keyboard.cursor do
        io.write("\b")
    end

    -- erase letters
    for _ = 1, #keyboard.line do
        io.write(" ")
    end

    -- move back to start
    for _ = 1, #keyboard.line do
        io.write("\b")
    end

    keyboard.cursor = 0
    keyboard.line = {}
end

--- Split a string into a table per-character
---@param str string
---@return string[]
local function split(str)
    return { str:match((str:gsub(".", "(.)"))) }
end

--- read a line, returning on enter. this differs from standard io.read() because it supports arrow keys, ctrl+backspace, etc.
function keyboard._read()
    keyboard.line = {}

    local control_character = 0

    while true do
        if control_character > 1 then
            keyboard._getc()

            control_character = control_character - 1

            goto continue
        end

        local char, key_code = keyboard._getc()

        if control_character == 1 then
            --[[
                - A up
                - B down
                - C right
                - D left
            ]]
            ({
                ["A"] = function()
                    local newpos = keyboard.history_pos + 1

                    if newpos > #keyboard.history then
                        return
                    end

                    if keyboard.history[newpos] then
                        keyboard._clear()

                        local history_line = keyboard.history[newpos]

                        keyboard.line = split(history_line)
                        keyboard.cursor = #history_line
                        io.write(history_line)

                        keyboard.history_pos = newpos
                    end
                end,
                ["B"] = function()
                    local newpos = keyboard.history_pos - 1

                    keyboard._clear()

                    if newpos < 1 then
                        keyboard.history_pos = 0

                        return
                    end

                    if keyboard.history[newpos] then
                        local history_line = keyboard.history[newpos]

                        keyboard.line = split(history_line)
                        keyboard.cursor = #history_line
                        io.write(history_line)

                        keyboard.history_pos = newpos
                    end
                end,
                ["C"] = function()
                    -- TODO disabled until i get un-lazy enough to fix text printing wrong when cursor is different from text length
                    --[[
                    if keyboard.cursor < #line then
                        io.write(string.char(0x1b, 0x5b, 0x43))

                        keyboard.cursor = keyboard.cursor + 1
                    end
                    ]]
                end,
                ["D"] = function()
                    --[[
                    if keyboard.cursor > 0 then
                        io.write(string.char(8))

                        keyboard.cursor = keyboard.cursor - 1
                    end
                    ]]
                end
            })[char]()

            control_character = 0

            goto continue
        end

        if key_code == 10 then
            -- enter
            io.write("\n")

            break
        elseif key_code == 23 then
            -- CTRL+backspace
            keyboard._clear()
        elseif key_code == 127 then
            -- backspace

            -- move back, print space, move forward
            if keyboard.cursor > 0 then
                io.write("\b \b")

                table.remove(keyboard.line, keyboard.cursor)

                keyboard.cursor = keyboard.cursor - 1
            end
        elseif key_code == 27 then
            -- esc (only used for direction keys)
            -- TODO pressing escape causes inputs to be ignored for 2 more keys

            -- do a silly little dance

            -- ignore inputs until control character is done printing
            control_character = 2
        else
            io.write(char)

            keyboard.cursor = keyboard.cursor + 1

            table.insert(keyboard.line, char)
        end

        ::continue::
    end

    return table.concat(keyboard.line)
end

function keyboard._getc()
    local char = io.read(1)

    return char, string.byte(char)
end

function keyboard._print_prompt()
    io.write(" > ")
end

return keyboard
