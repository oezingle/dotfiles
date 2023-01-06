local fs = require("src.util.fs")

local json_path = fs.directories.config .. "lib/gemoji/db/emoji.json"


local json

---@return GmojiEmoji[]
local function get_json()
    if not json then
        json = fs.json.load(json_path)
    end

    return json
end

---@type string[]
local categories

---@return string[]
local function get_categories()
    if not categories then
        categories = {}

        local emojis = get_json()

        local last_category = nil

        for _, emoji in ipairs(emojis) do
            local category = emoji.category

            if last_category ~= category then
                table.insert(categories, category)
            end
        end
    end

    return categories
end

---@return DeserializedEmoji[]
local function find_category(category)
    ---@type GmojiEmoji[]
    local category_list = {}

    local emojis = get_json()

    for _, emoji in ipairs(emojis) do
        if emoji.category == category then
            table.insert(category_list, emoji)
        end
    end

    return category_list
end

---@return DeserializedEmoji[]
local function find_term(term)
    ---@type GmojiEmoji[]
    local result = {}

    local emojis = get_json()

    for _, emoji in ipairs(emojis) do
        local is_match = false

        if emoji.description:find(term) then
            is_match = true
        end

        if not is_match then
            for _, tag in ipairs(emoji.tags) do
                if tag == term then
                    is_match = true

                    break
                end
            end
        end

        if not is_match then
            for _, alias in ipairs(emoji.aliases) do
                if alias:find(term) then
                    is_match = true

                    break
                end
            end
        end

        if is_match then
            table.insert(result, emoji)
        end
    end

    return result
end

get_json()

return {
    find_category = find_category,
    find_term = find_term,

    get_categories = get_categories,
    _get_json = get_json
}
