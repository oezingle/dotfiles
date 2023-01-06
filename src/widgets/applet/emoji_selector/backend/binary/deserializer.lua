-- TODO C API library http://lua-users.org/wiki/SimpleLuaApiExample

local offsets = require("src.widgets.applet.emoji_selector.backend.binary.offsets")

--- Split a string into an array by delimiter
---@param array string
---@param delimiter string
---@return string[]
local function split(array, delimiter)
    local matches = {}

    local index = 1

    for match in string.gmatch(array, "[^" .. delimiter .. "]+") do
        matches[index] = match

        index = index + 1
    end

    return matches
end

--- Deserialize an emoji
---@param chunk string
---@param tags string[]
---@param categories string[]
---@return DeserializedEmoji
local function deserialize_emoji(chunk, tags, categories)
    local emoji = chunk:sub(offsets.UNICODE_START, offsets.UNICODE_END):gsub("%z", "")

    --[[
    local tag_list = {}

    for i = offsets.TAG_START, offsets.TAG_END do
        local tag = chunk:byte(i, i)

        if tag ~= 0 then
            table.insert(tag_list, tags[tag])
        end
    end
    ]]

    -- local category = categories[chunk:byte(offsets.CATEGORY_START, offsets.CATEGORY_END)]

    local description = chunk:sub(offsets.DESCRIPTION_START, offsets.DESCRIPTION_END)

    -- local aliases = split(chunk:sub(offsets.ALIASES_START, offsets.ALIASES_END), "|")

    return {
        emoji       = emoji,
        --tags        = tag_list,
        --category    = category,
        description = description,
        --aliases     = aliases
    }
end

--- Read the header of the binary file
---@param file file*
local function read_header(file)
    file:seek("set", 16)

    local tags = split(file:read("l"), "|")

    local categories = split(file:read("l"), "|")

    local tag_indexes = {}

    for index, tag in ipairs(tags) do
        tag_indexes[tag] = index
    end

    local category_indexes = {}

    for index, category in ipairs(categories) do
        category_indexes[category] = index
    end

    return {
        tags = tags,
        categories = categories,

        tag_indexes = tag_indexes,
        category_indexes = category_indexes,

        pos = file:seek()
    }
end

--- Find all emojis that match the search term
--- Searches description, aliases, and tags
---@param path string
---@param term string
local function find_term(path, term)
    term = term or ""

    term = term:lower()

    local file = io.open(path, "rb")

    assert(file, "File error")

    local header = read_header(file)

    ---@type number|nil
    local tag_index = header.tag_indexes[term]

    ---@type DeserializedEmoji[]
    local emojis = {}

    while true do        
        local chunk = file:read(1)

        file:seek("cur", -1)

        if not chunk then
            break
        end

        if string.byte(chunk, 1, 1) == 0 then
            file:seek("cur", 1)
        end

        ---@type string
        local chunk = file:read(128)

        local is_match = false

        do
            local description = chunk:sub(offsets.DESCRIPTION_START, offsets.DESCRIPTION_END)

            if description:lower():find(term) then
                is_match = true
            end
        end

        if not is_match then
            local tag1, tag2, tag3, tag4 = chunk:byte(offsets.TAG_START, offsets.TAG_END)

            if tag1 == tag_index or tag2 == tag_index or tag3 == tag_index or tag4 == tag_index then
                is_match = true
            end
        end

        if not is_match then
            local aliases = chunk:sub(offsets.ALIASES_START, offsets.ALIASES_END)

            if aliases:lower():find(term) then
                is_match = true
            end
        end

        if is_match then
            table.insert(emojis, deserialize_emoji(chunk, header.tags, header.categories))
        end
    end

    file:close()

    return emojis
end

--- Helper function: check if an emoji chunk has a given tag
---@param chunk string
---@param tag integer
---@return boolean
local function has_tag(chunk, tag)
    for i = offsets.TAG_START, offsets.TAG_END do
        local chunk_tag = chunk:byte(i, i)

        if chunk_tag == tag then
            return true
        end
    end

    return false
end

--- Find all emojis that have a given tag
---@param path string
---@param tag string
local function find_tag(path, tag)
    local file = io.open(path, "rb")

    assert(file, "File error")

    local header = read_header(file)

    local tag_index = header.tag_indexes[tag]

    ---@type DeserializedEmoji[]
    local emojis = {}

    while true do
        local chunk = file:read(1)

        file:seek("cur", -1)

        if not chunk then
            break
        end

        if string.byte(chunk, 1, 1) == 0 then
            file:seek("cur", 1)
        end

        ---@type string
        local chunk = file:read(128)

        if has_tag(chunk, tag_index) then
            table.insert(emojis, deserialize_emoji(chunk, header.tags, header.categories))
        end
    end

    file:close()

    return emojis
end

--- TODO doesn't work for Smileys & Emotions - first byte of chunk is NULL
--- Find all emojis in a category
---@param path string
---@param category string
---@return DeserializedEmoji[]
local function find_category(path, category)
    local file = io.open(path, "rb")

    assert(file, "File error")

    local header = read_header(file)

    local category_index = header.category_indexes[category] or 0

    if category_index == 0 then
        return {}
    end

    local category_from_header = 1

    while category_from_header < category_index do
        local pos = file:seek()

        local chunk = file:read(1)

        file:seek("set", pos + 128)

        local byte = string.byte(chunk, 1, 1)

        if byte == 0 then
            category_from_header = category_from_header + 1

            file:seek("cur", 1)
        end
    end

    local emojis = {}

    file:seek("cur", -128)

    while true do
        local chunk = file:read(128)

        if not chunk then
            break
        end

        local byte = string.byte(chunk, 1, 1)

        if byte == 0 then
            break
        end

        table.insert(emojis, deserialize_emoji(chunk, header.tags, header.categories))
    end

    file:close()

    return emojis
end

local function get_categories(path)
    local file = io.open(path, "rb")

    assert(file, "File error")

    local header = read_header(file)

    file:close()

    return header.categories
end

local function get_tags(path)
    local file = io.open(path, "rb")

    assert(file, "File error")

    local header = read_header(file)

    file:close()

    return header.tags
end

return {
    find_term = find_term,
    find_category = find_category,
    find_tag = find_tag,

    get_categories = get_categories,
    get_tags = get_tags,

    _read_header = read_header
}
