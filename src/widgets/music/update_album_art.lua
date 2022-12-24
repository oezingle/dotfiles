local spawn = require("src.agnostic.spawn")
local dirs = require("src.util.fs").dirs
local cache_dir = dirs.cache
local config_dir = dirs.config

local gsurface = require("gears.surface")
local gtimer = require("gears.timer")

-- save the last url and song data to check if a new download has to be made
local last_song_info = ""
-- save the last path so art can be restored
local last_art_path = ""

--- Update the album art display
---@param widget any
---@param metadata PlayerctlMetadataQueryResult
local function update_album_art(widget, metadata)
    if not metadata or not next(metadata) or #metadata.art_url == 0 then
        widget.image = config_dir .. "icon/music/musical-notes.svg"
    else
        local art_url = metadata.art_url

        local song_info = metadata.artist .. metadata.title

        if song_info ~= last_song_info then
            -- check if we use wget to pull the image or just take a file:// path
            if art_url:sub(1, 7) == "file://" then
                last_art_path = art_url:sub(7)

                widget.image = last_art_path
            else
                spawn(
                    "cd " .. cache_dir .. "; wget -O album_art \"" .. art_url .. "\"",
                    function()
                        last_art_path = cache_dir .. "album_art"

                        -- clears cache :)
                        widget.image = gsurface.load_uncached(last_art_path)
                    end
                )
            end

            last_song_info = song_info
        else
            -- TODO is very wasteful
            widget.image = gsurface.load(last_art_path)
        end
    end
end

return update_album_art
