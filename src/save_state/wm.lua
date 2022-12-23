local fs = require("src.util.fs")
local json = require("lib.json")

local floor = math.floor
local cache_dir = fs.dirs.cache

local FILE_PATH = cache_dir .. "wm.json"

local WM_STATE = {}

--[[
    wm.json:
    {
        "screens": [
            {
                "geometry": {
                    "width": x,
                    "height": y,
                    "dpi": d
                },
                "primary": true
                "tags": {
                    "0": {
                        "layout": "floating"
                        "master_width_factor": 600,
                        "master_count": 1,
                        "column_count": 2
                    }
                },
                "selected_tags": [ "0" ],
                "selected_tag": "0"
            }
        ]
    }
]]

---@class TagTable
---@field layout string
---@field master_width_factor number
---@field master_count integer
---@field column_count integer

---@class ScreenTable
---@field dpi number
---@field geometry Geometry
---@field primary boolean
---@field selected_tags string[]
---@field selected_tag string[]
---@field tags table<string, TagTable>

--- Convert a screen to a json-serializable table
---@param s table an AwesomeWM Screen
---@return ScreenTable
local function screen_table(s)
    local selected_tags = {}

    for _, t in ipairs(s.selected_tags) do
        table.insert(selected_tags, t.name)
    end

    local tags = {}

    for _, t in ipairs(s.tags) do
        tags[t.name] = {
            layout = t.layout.name,
            master_width_factor = t.master_width_factor,
            master_count = t.master_count,
            column_count = t.column_count
        }
    end

    return {
        dpi = s.dpi,
        geometry = {
            width = s.geometry.width,
            height = s.geometry.height,
        },
        primary = s == screen.primary,

        selected_tags = selected_tags,
        selected_tag = s.selected_tag and s.selected_tag.name,

        tags = tags,
    }
end

--- Check if two tables have equal keys. Ignore values
---@param t1 table
---@param t2 table
---@return boolean
local function keys_equal(t1, t2)
    for key, _ in pairs(t1) do
        if t2[key] == nil then
            return false
        end
    end

    for key, _ in pairs(t2) do
        if t1[key] == nil then
            return false
        end
    end

    return true
end

--- Check if two screen tables are equal
---@param s1 ScreenTable
---@param s2 ScreenTable
---@return boolean
local function screen_equal(s1, s2)
    
    if floor(s1.dpi) ~= floor(s2.dpi) then
        return false
    end

    if s1.geometry.width ~= s2.geometry.width then
        return false
    end

    if s1.geometry.height ~= s2.geometry.height then
        return false
    end

    if s1.primary ~= s2.primary then
        return false
    end

    -- tags -> check keys align
    if not keys_equal(s1.tags, s2.tags) then
        return false
    end

    return true
end

--- Find the saved WM_STATE screen data for a given screen
---@param s table
---@return ScreenTable|nil
local function get_saved_screen(s)
    if not WM_STATE or not WM_STATE.screens then
        return nil
    end

    local s_table = screen_table(s)

    for _, saved_screen in ipairs(WM_STATE.screens) do
        if screen_equal(saved_screen, s_table) then
            return saved_screen
        end
    end
end

local print = require("src.agnostic.print")

local function load_state()
    local contents = fs.read(FILE_PATH)

    if contents then
        WM_STATE = json.decode(contents)
    end

    if WM_STATE then
        --[[
            reasons to invalidate:
                - screen count changes -> for s in screen if saved.geometry != s.geometry then invalidate
                - per screen
                    - screen's geometry changes
                    - tag count changes
                    - tag names change
                    - screen DPI changes
        ]]

        if not WM_STATE.screens then
            return
        end

        if screen.count() ~= #WM_STATE.screens then
            WM_STATE.screens = nil

            return
        end

        for s in screen do
            if not get_saved_screen(s) then
                print("invalidated WM_STATE: saved screen not found")

                WM_STATE.screens = nil

                return
            end
        end
    end
end

load_state()

local function save_state()
    WM_STATE = WM_STATE or {}

    WM_STATE.screens = {}

    for s in screen do        
        table.insert(WM_STATE.screens, screen_table(s))
    end

    local file_contents = json.encode(WM_STATE)

    fs.write(FILE_PATH, file_contents)
end

awesome.connect_signal("exit", function()
    save_state()
end)

--- Restore saved tags for every screen
local function restore_tags()
    if WM_STATE and WM_STATE.screens then
        for s in screen do
            local saved_screen = get_saved_screen(s)

            if saved_screen then
                for _, t in ipairs(s.tags) do
                    -- load tags
                    local saved_tag = saved_screen.tags[t.name]

                    -- set layout
                    local layouts = t.layouts

                    for _, layout in ipairs(layouts) do
                        if layout.name == saved_tag.layout then
                            t.layout = layout
                        end
                    end

                    t.selected = false

                    for _, selected_tag in ipairs(saved_screen.selected_tags) do
                        if t.name == selected_tag then
                            t.selected = true
                        end
                    end
                end
            end
        end
    end
end

return {
    state = WM_STATE,
    restore_tags = restore_tags,
    get_saved_screen = get_saved_screen
}
