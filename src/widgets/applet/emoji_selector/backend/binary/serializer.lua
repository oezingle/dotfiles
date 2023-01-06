
local offsets = require("src.widgets.applet.emoji_selector.backend.binary.offsets")

--[[
--- Turn the total_offset into something writable
---@param input number
---@return string[]
local function writeable_bytes(input)
    local bytes = {}

    while input ~= 0 do
        table.insert(bytes, 1, string.char(input % 256))

        input = math.floor(input / 256)
    end

    return bytes
end

--- Write an integer number to a file
---@param file file*
---@param number integer
---@param size integer the address width of the number
local function write_number(file, number, size)
    local pos = file:seek()

    local bytes = writeable_bytes(number)

    file:seek("set", pos + size - #bytes)

    file:write(unpack(bytes))
end
]]

local TAG_MAX_LENGTH = 16
local CATEGORY_MAX_LENGTH = 32

local MAX_TAGS = 255

local MAX_TAG_COUNT = offsets.struct.TAG
local MAX_ALIAS_LENGTH = offsets.struct.ALIASES -- got 44 (no seperator)
local MAX_DESCRIPTION_LENGTH = offsets.struct.DESCRIPTION -- got 44

--- Serialize an emoji
---@param file file*
---@param emoji GmojiEmoji
---@param category_indexes table<string, integer>
---@param tag_indexes table<string, integer>
local function serialize_emoji (file, emoji, category_indexes, tag_indexes)
    -- 4  bytes - Unicode
    -- 4  bytes - Tags
    -- 1  byte  - Category
    -- 55 bytes - Description (44)
    -- 64 bytes - Aliases (44)

    local start = file:seek()

    file:write(emoji.emoji)

    file:seek("set", start + offsets.TAG_START - 1)

    for _, tag in ipairs(emoji.tags) do
        local index = tag_indexes[tag]

        if index ~= nil then            
            file:write(string.char(index))
        end
    end

    file:seek("set", start + offsets.CATEGORY_START - 1)

    local category_index = category_indexes[emoji.category]

    assert(category_index ~= nil)

    file:write(string.char(category_index))
    
    file:seek("set", start + offsets.DESCRIPTION_START - 1)

    file:write(emoji.description)

    local aliases = table.concat(emoji.aliases, "|")

    file:seek("set", start + offsets.ALIASES_START - 1)

    file:write(aliases)

    file:seek("set", start + 128)
end

local function has_value (tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

--- Serialize the emojis
---@param emojis GmojiEmoji[]
---@param path string
local function serialize(emojis, path)
    local file = io.open(path, "wb")

    assert(file, "File error")

    file:write("Binary emojifile")

    file:seek("set", 16)

    local tags = {}

    do
        local tag_table = {}

        for _, emoji in ipairs(emojis) do
            assert(#emoji.tags <= MAX_TAG_COUNT, "Too many tags on emoji")

            for _, emoji_tag in ipairs(emoji.tags) do
                local description_contains = string.find(string.lower(emoji.description), emoji_tag)

                -- Ignore tags that are contained in descriptions
                if not description_contains then
                    assert(#emoji_tag <= TAG_MAX_LENGTH, "Tag longer than 16 chars")

                    if not tag_table[emoji_tag] then
                        tag_table[emoji_tag] = 0
                    end

                    tag_table[emoji_tag] = tag_table[emoji_tag] + 1
                end
            end
        end

        local index = 1

        for tag, count in pairs(tag_table) do
            if count > 1 then
                tags[index] = tag

                index = index + 1
            end
        end

        for _, emoji in ipairs(emojis) do
            for index, emoji_tag in ipairs(emoji.tags) do
                if not tag_table[emoji_tag] or tag_table[emoji_tag] < 2 then
                    table.remove(emoji.tags, index)

                    table.insert(emoji.aliases, emoji_tag)
                end
            end
        end
    end

    local tag_indexes = {}

    for index, tag in ipairs(tags) do
        tag_indexes[tag] = index

        --[[
        local pos = file:seek()

        file:write(tag)

        file:seek("set", pos + 16)
        ]]
    end

    assert(#tags <= MAX_TAGS)

    file:write(table.concat(tags, "|"), "\n")

    -- file:seek("cur", 1)

    local categories = {}

    do
        for _, emoji in ipairs(emojis) do
            local category = emoji.category
            
            assert(#category <= CATEGORY_MAX_LENGTH, "Category longer than 32 chars")

            if not has_value(categories, category) then
                table.insert(categories, category)
            end
        end
    end

    local category_indexes = {}

    for index, category in ipairs(categories) do
        category_indexes[category] = index

        --[[
        local pos = file:seek()

        file:write(category)

        file:seek("set", pos + 32)
        ]]
    end

    file:write(table.concat(categories, "|"), "\n")

    local last_category = 1

    for _, emoji in ipairs(emojis) do
        local category_index = category_indexes[emoji.category]

        if last_category ~= category_index then
            file:seek("cur", 1)
        end

        last_category = category_index

        serialize_emoji(file, emoji, category_indexes, tag_indexes)       
        
        assert(#table.concat(emoji.aliases, "|") <= MAX_ALIAS_LENGTH)

        assert(#emoji.description <= MAX_DESCRIPTION_LENGTH)
    end

    file:flush()
    file:close()
end

return serialize
