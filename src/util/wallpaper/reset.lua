local fs = require("src.util.fs")
local hash = require("src.util.wallpaper.hash")

-- Reset the wallpaper directory
local function reset()
    fs.rm(fs.directories.wallpaper, true)

    fs.mkdir(fs.directories.wallpaper)
end

-- Reset the wallpaper config folder if needed.
---@param config Wallpaper.Config
local function reset_if_needed(config)
    local last_state_path = fs.directories.wallpaper .. "last_values.json"

    local last_state = {}

    if fs.exists(last_state_path) then
        last_state = fs.json.load(last_state_path)
    end

    -- last_state was not recorded, so we have to reset
    if not next(last_state) then
        reset()

        goto write_state
    end

    for last_identifier, last_path in pairs(last_state) do
        local last_dir = fs.directories.wallpaper .. hash(last_identifier) .. "/"

        local path_match_found = false

        for identifier, path in pairs(config.table) do
            local dir = fs.directories.wallpaper .. hash(identifier) .. "/"

            if path == last_path then
                if identifier ~= last_identifier then
                    fs.mv(last_dir, dir)
                end

                path_match_found = true
            end
        end

        if not path_match_found then
            fs.rm(last_dir, true)
        end
    end

    ::write_state::

    fs.json.dump(last_state_path, config.table)
end

return reset_if_needed
