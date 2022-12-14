local test = require("lib.test")

local backend = require("src.widgets.applet.emoji_selector.backend")

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

test.suite(
    "emoji_selector.backend",
    test.test(function()
        local categories = backend.get_categories()

        local category_indexes = {}

        for index, category in ipairs(categories) do
            category_indexes[category] = index
        end

        for _, emoji in ipairs(backend._get_json()) do
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
            "๐ต๐๐ฆ๐ฆง๐ถ๐๐ฆฎ๐โ๐ฆบ๐ฉ๐บ๐ฆ๐ฆ๐ฑ๐๐โโฌ๐ฆ๐ฏ๐๐๐ด๐๐ฆ๐ฆ๐ฆ๐ฆฌ๐ฎ๐๐๐๐ท๐๐๐ฝ๐๐๐๐ช๐ซ๐ฆ๐ฆ๐๐ฆฃ๐ฆ๐ฆ๐ญ๐๐๐น๐ฐ๐๐ฟ๏ธ๐ฆซ๐ฆ๐ฆ๐ป๐ปโโ๏ธ๐จ๐ผ๐ฆฅ๐ฆฆ๐ฆจ๐ฆ๐ฆก๐พ๐ฆ๐๐๐ฃ๐ค๐ฅ๐ฆ๐ง๐๏ธ๐ฆ๐ฆ๐ฆข๐ฆ๐ฆค๐ชถ๐ฆฉ๐ฆ๐ฆ๐ธ๐๐ข๐ฆ๐๐ฒ๐๐ฆ๐ฆ๐ณ๐๐ฌ๐ฆญ๐๐ ๐ก๐ฆ๐๐๐ชธ๐๐ฆ๐๐๐๐ชฒ๐๐ฆ๐ชณ๐ท๏ธ๐ธ๏ธ๐ฆ๐ฆ๐ชฐ๐ชฑ๐ฆ ๐๐ธ๐ฎ๐ชท๐ต๏ธ๐น๐ฅ๐บ๐ป๐ผ๐ท๐ฑ๐ชด๐ฒ๐ณ๐ด๐ต๐พ๐ฟโ๏ธ๐๐๐๐๐ชน๐ชบ")
    end, "backend.find_category()")
)

test.profile(function()
    local matches = backend.find_category("Animals & Nature")

    local str = concat_emoji_results(matches)

    assert(str ==
        "๐ต๐๐ฆ๐ฆง๐ถ๐๐ฆฎ๐โ๐ฆบ๐ฉ๐บ๐ฆ๐ฆ๐ฑ๐๐โโฌ๐ฆ๐ฏ๐๐๐ด๐๐ฆ๐ฆ๐ฆ๐ฆฌ๐ฎ๐๐๐๐ท๐๐๐ฝ๐๐๐๐ช๐ซ๐ฆ๐ฆ๐๐ฆฃ๐ฆ๐ฆ๐ญ๐๐๐น๐ฐ๐๐ฟ๏ธ๐ฆซ๐ฆ๐ฆ๐ป๐ปโโ๏ธ๐จ๐ผ๐ฆฅ๐ฆฆ๐ฆจ๐ฆ๐ฆก๐พ๐ฆ๐๐๐ฃ๐ค๐ฅ๐ฆ๐ง๐๏ธ๐ฆ๐ฆ๐ฆข๐ฆ๐ฆค๐ชถ๐ฆฉ๐ฆ๐ฆ๐ธ๐๐ข๐ฆ๐๐ฒ๐๐ฆ๐ฆ๐ณ๐๐ฌ๐ฆญ๐๐ ๐ก๐ฆ๐๐๐ชธ๐๐ฆ๐๐๐๐ชฒ๐๐ฆ๐ชณ๐ท๏ธ๐ธ๏ธ๐ฆ๐ฆ๐ชฐ๐ชฑ๐ฆ ๐๐ธ๐ฎ๐ชท๐ต๏ธ๐น๐ฅ๐บ๐ป๐ผ๐ท๐ฑ๐ชด๐ฒ๐ณ๐ด๐ต๐พ๐ฟโ๏ธ๐๐๐๐๐ชน๐ชบ")
end, "backend.find_category()")