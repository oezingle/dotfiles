
local fs = require("src.util.fs")
local cache_dir = require("src.util.fs.directories").cache
local json = require("lib.json")

local JSON_PATH = cache_dir .. "notifications.json"

---@type boolean
local DO_NOT_DISTURB = false

local function load_state() 
    local notif_file = fs.read(JSON_PATH)

    if not notif_file then
        return
    end

    local notif_json = json.decode(notif_file)

    DO_NOT_DISTURB = notif_json.is_do_not_disturb == true
end

load_state()

local function save_state(table)
    table = table or {}

    table.is_do_not_disturb = DO_NOT_DISTURB

    local notif_file = json.encode(table)

    fs.write(JSON_PATH, notif_file)
end

local function is_do_not_disturb ()     
    return DO_NOT_DISTURB
end

--- Set do not disturb state
---@param value boolean
local function set_do_not_disturb(value)
    DO_NOT_DISTURB = value
end

--- Toggle do not disturb on and off
local function toggle_do_not_disturb ()
    DO_NOT_DISTURB = not DO_NOT_DISTURB
end

-- todo add notifications in notificaiton center, move to save_state
awesome.connect_signal("exit", function ()
    save_state()
end)

return {
    get_state = is_do_not_disturb,
    toggle = toggle_do_not_disturb,
    set = set_do_not_disturb
}