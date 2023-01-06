local fs        = require("src.util.fs")

-- TODO folder_of_this_file

local serializer   = require("src.widgets.applet.emoji_selector.backend.binary.serializer")

local paths = require("src.widgets.applet.emoji_selector.backend.binary.paths")

--- Get the Mtime of a given file
---@param path string
local function mtime(path)
    local f = io.popen("stat -c %Y " .. path)

    assert(f)

    local last_modified = f:read()

    return tonumber(last_modified)
end

local function ensure_dir()
    if fs.exists(paths.dir) and not fs.isdir(paths.dir) then
        fs.rm(paths.dir, true)
    end

    local mtime_file = paths.dir .. "mtime.json"

    if fs.exists(paths.dir) and (not fs.exists(mtime_file) or fs.json.load(mtime_file).mtime ~= mtime(paths.json_file)) then
        fs.rm(paths.dir, true)
    end

    if not fs.exists(paths.dir) then
        fs.mkdir(paths.dir)

        fs.json.dump(mtime_file, { mtime = mtime(paths.json_file) })
    end
end

-- TODO store mtime of lib/gemoji/db/emoji.json so that files can be recreated

--[[
--- Slow alternative to find_term
---@param emojis GmojiEmoji[]
---@param term string
---@return GmojiEmoji[]
local function find_term_slow(emojis, term)
    term = term:lower()

    local results = {}

    for _, emoji in ipairs(emojis) do
        local is_match = false

        if emoji.description:lower():find(term) then
            is_match = true
        end

        if not is_match then
            for _, alias in ipairs(emoji.aliases) do
                if alias:lower():find(term) then
                    is_match = true

                    break
                end
            end
        end

        if is_match then
            table.insert(results, emoji)
        end
    end

    return results
end
]]

--- Ensure that the emoji list has been serialized
---@param recreate boolean?
local function load_emojis(recreate)
    
    recreate = recreate or false

    if recreate and fs.exists(paths.dir) then
        fs.rm(paths.dir, true)
    end
    
    ensure_dir()

    if not fs.exists(paths.bin) then
        ---@type GmojiEmoji[]
        local emojis = fs.json.load(paths.json_file)

        serializer(emojis, paths.bin)
    end

    --[[
    for _, category in ipairs(deserializer.get_categories(binary_file)) do
        print(category)
    end
    ]]

    --[[
    for _, tag in ipairs(deserializer.get_tags(binary_file)) do
        print(tag)
    end
    ]]

    --[[
        Smileys & Emotion
        People & Body
        Animals & Nature
        Food & Drink
        Travel & Places
        Activities
        Objects
        Symbols
        Flags
    ]]

    -- TODO find_tag("time") returns 0 emoji
end

return load_emojis