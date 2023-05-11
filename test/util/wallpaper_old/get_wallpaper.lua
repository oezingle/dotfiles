local test = require("lib.test")

-- TODO rewrite for Promisified wallpapers API

test.require_awesome("get_wallpaper", function(name)
    local get_wallpaper = require("src.util.wallpaper_old.get_wallpaper")

    test.suite(
        name,
        test.test(function()
            get_wallpaper()
        end, "Default Size"),
        test.test(function()
            get_wallpaper(128, 128)
        end, "No Blur"),
        test.test(function()
            get_wallpaper(128, 128, true)
        end, "Blurred")
    )
end)
