
local awful = require("awful")
local gfs = require("gears.filesystem")
local config_dir = gfs.get_configuration_dir()

-- save the last url to check if a new download has to be made
local last_art_url = ""

local function update_album_art(widget)
    awful.spawn.easy_async(
        "playerctl metadata --format '{{ mpris:artUrl }}'",
        function(response)
            -- remove \n from the url
            local url = response:sub(1, -2)

            if url == "No players found" or not url or #url == 0 then
                widget.image = config_dir .. "icon/music/musical-notes.svg"
            else
                if url ~= last_art_url then
                    -- check if we use wget to pull the image or just take a file:// path
                    if url:sub(1, 7) == "file://" then
                        widget.image = url:sub(7)
                    else
                        awful.spawn.easy_async_with_shell(
                            "cd " .. config_dir .. "cache; wget -O album_art \"" .. url .. "\"",
                            function ()
                                widget.image = ""

                                widget.image = config_dir .. "cache/album_art"
                            end
                        )
                    end

                    last_art_url = url
                end
            end
        end
    )
end

return update_album_art