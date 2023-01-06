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
            "🐵🐒🦍🦧🐶🐕🦮🐕‍🦺🐩🐺🦊🦝🐱🐈🐈‍⬛🦁🐯🐅🐆🐴🐎🦄🦓🦌🦬🐮🐂🐃🐄🐷🐖🐗🐽🐏🐑🐐🐪🐫🦙🦒🐘🦣🦏🦛🐭🐁🐀🐹🐰🐇🐿️🦫🦔🦇🐻🐻‍❄️🐨🐼🦥🦦🦨🦘🦡🐾🦃🐔🐓🐣🐤🐥🐦🐧🕊️🦅🦆🦢🦉🦤🪶🦩🦚🦜🐸🐊🐢🦎🐍🐲🐉🦕🦖🐳🐋🐬🦭🐟🐠🐡🦈🐙🐚🪸🐌🦋🐛🐜🐝🪲🐞🦗🪳🕷️🕸️🦂🦟🪰🪱🦠💐🌸💮🪷🏵️🌹🥀🌺🌻🌼🌷🌱🪴🌲🌳🌴🌵🌾🌿☘️🍀🍁🍂🍃🪹🪺")
    end, "backend.find_category()")
)

test.profile(function()
    local matches = backend.find_category("Animals & Nature")

    local str = concat_emoji_results(matches)

    assert(str ==
        "🐵🐒🦍🦧🐶🐕🦮🐕‍🦺🐩🐺🦊🦝🐱🐈🐈‍⬛🦁🐯🐅🐆🐴🐎🦄🦓🦌🦬🐮🐂🐃🐄🐷🐖🐗🐽🐏🐑🐐🐪🐫🦙🦒🐘🦣🦏🦛🐭🐁🐀🐹🐰🐇🐿️🦫🦔🦇🐻🐻‍❄️🐨🐼🦥🦦🦨🦘🦡🐾🦃🐔🐓🐣🐤🐥🐦🐧🕊️🦅🦆🦢🦉🦤🪶🦩🦚🦜🐸🐊🐢🦎🐍🐲🐉🦕🦖🐳🐋🐬🦭🐟🐠🐡🦈🐙🐚🪸🐌🦋🐛🐜🐝🪲🐞🦗🪳🕷️🕸️🦂🦟🪰🪱🦠💐🌸💮🪷🏵️🌹🥀🌺🌻🌼🌷🌱🪴🌲🌳🌴🌵🌾🌿☘️🍀🍁🍂🍃🪹🪺")
end, "backend.find_category()")