local build_cache = require("src.widgets.applet.emoji_selector.backend.binary.build_cache")
local deserializer = require("src.widgets.applet.emoji_selector.backend.binary.deserializer")
local paths = require("src.widgets.applet.emoji_selector.backend.binary.paths")

build_cache()

return {
    find_term = function(term)
        return deserializer.find_term(paths.bin, term)
    end,
    find_category = function (category)
        return deserializer.find_category(paths.bin, category)
    end,

    get_categories = function ()
        return deserializer.get_categories(paths.bin)
    end
}
