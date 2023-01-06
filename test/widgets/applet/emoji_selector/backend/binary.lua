local test = require("lib.test")

local fs_json = require("src.util.fs.json")

local build_cache = require("src.widgets.applet.emoji_selector.backend.binary.build_cache")
local deserializer = require("src.widgets.applet.emoji_selector.backend.binary.deserializer")
local emoji_paths = require("src.widgets.applet.emoji_selector.backend.binary.paths")

local backend = require("src.widgets.applet.emoji_selector.backend.binary")

--- Concatenate emojis into one string
---@param matches DeserializedEmoji[]
---@return string
local function concat_emoji_results(matches)
    local str = ""

    for _, match in ipairs(matches) do
        str = str .. match.emoji
    end

    return str
end

---@type GmojiEmoji[]
local emojis

test.suite(
    "emoji_selector.backend.binary",
    test.test(function()
        emojis = fs_json.load(emoji_paths.json_file)
    end, "load emoji JSON"),

    test.test(function()
        build_cache(true)
    end, "build_cache()"),
    test.test(function()
        local file = io.open(emoji_paths.bin, "rb")

        assert(file)

        assert(file:read(16) == "Binary emojifile")
    end, "serializer - header"),

    test.test(function()
        local tags = deserializer.get_tags(emoji_paths.bin)

        local tag_indexes = {}

        for index, tag in ipairs(tags) do
            tag_indexes[tag] = index
        end

        for _, emoji in ipairs(emojis) do
            for _, tag in ipairs(emoji.tags) do
                tag_indexes[tag] = nil
            end

            if not next(tag_indexes) then
                return
            end
        end

        error("There are tags left")
    end, "deserializer.get_tags()"),
    test.test(function()
        local categories = backend.get_categories()

        local category_indexes = {}

        for index, category in ipairs(categories) do
            category_indexes[category] = index
        end

        for _, emoji in ipairs(emojis) do
            local category_index = category_indexes[emoji.category]

            assert(category_index)
        end
    end, "backend.get_categories()"),

    test.test(function()
        local matches = backend.find_term("dog")

        assert(#matches == 6)
    end, "backend.find_term()"),
    test.test(function()
        local matches = backend.find_category("Animals & Nature")

        local str = concat_emoji_results(matches)

        assert(str ==
            "🐵🐒🦍🦧🐶🐕🦮🐕‍🦺🐩🐺🦊🦝🐱🐈🐈‍⬛🦁🐯🐅🐆🐴🐎🦄🦓🦌🦬🐮🐂🐃🐄🐷🐖🐗🐽🐏🐑🐐🐪🐫🦙🦒🐘🦣🦏🦛🐭🐁🐀🐹🐰🐇🐿️🦫🦔🦇🐻🐻‍❄️🐨🐼🦥🦦🦨🦘🦡🐾🦃🐔🐓🐣🐤🐥🐦🐧🕊️🦅🦆🦢🦉🦤🪶🦩🦚🦜🐸🐊🐢🦎🐍🐲🐉🦕🦖🐳🐋🐬🦭🐟🐠🐡🦈🐙🐚🪸🐌🦋🐛🐜🐝🪲🐞🦗🪳🕷️🕸️🦂🦟🪰🪱🦠💐🌸💮🪷🏵️🌹🥀🌺🌻🌼🌷🌱🪴🌲🌳🌴🌵🌾🌿☘️🍀🍁🍂🍃🪹🪺")
    end, "backend.find_category()")
)

--[[
test.profile(function()
    local matches = backend.find_category("Animals & Nature")

    local str = concat_emoji_results(matches)

    assert(str ==
        "🐵🐒🦍🦧🐶🐕🦮🐕‍🦺🐩🐺🦊🦝🐱🐈🐈‍⬛🦁🐯🐅🐆🐴🐎🦄🦓🦌🦬🐮🐂🐃🐄🐷🐖🐗🐽🐏🐑🐐🐪🐫🦙🦒🐘🦣🦏🦛🐭🐁🐀🐹🐰🐇🐿️🦫🦔🦇🐻🐻‍❄️🐨🐼🦥🦦🦨🦘🦡🐾🦃🐔🐓🐣🐤🐥🐦🐧🕊️🦅🦆🦢🦉🦤🪶🦩🦚🦜🐸🐊🐢🦎🐍🐲🐉🦕🦖🐳🐋🐬🦭🐟🐠🐡🦈🐙🐚🪸🐌🦋🐛🐜🐝🪲🐞🦗🪳🕷️🕸️🦂🦟🪰🪱🦠💐🌸💮🪷🏵️🌹🥀🌺🌻🌼🌷🌱🪴🌲🌳🌴🌵🌾🌿☘️🍀🍁🍂🍃🪹🪺")
end, "backend.find_category()")
]]

--[[
    ---@type GmojiEmoji[]
    local emojis

    profile(function()
        emojis = fs.json.load(paths.json_file)

        local matches = find_term_slow(emojis, "dog")

        for _, match in ipairs(matches) do
            print(match.emoji, match.category, match.description)
        end
    end, "find_term_slow()")

    profile(function()
        local matches = find_term_slow(emojis, "dog")

        for _, match in ipairs(matches) do
            print(match.emoji, match.category, match.description)
        end
    end, "find_term_slow()")

    profile(function()
        local matches = deserializer.find_term(paths.bin, "dog")

        for _, match in ipairs(matches) do
            print(match.emoji, match.category, match.description, table.concat(match.tags, ", "))
        end
    end, "deserializer.find_term()")

    profile(function()
        local matches = deserializer.find_category(paths.bin, "Animals & Nature")

        local str = ""

        for _, match in ipairs(matches) do
            str = str .. match.emoji
        end

        print(str)
    end, "deserializer.find_category")
]]
