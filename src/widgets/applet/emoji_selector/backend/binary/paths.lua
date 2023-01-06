local dirs = require("src.util.fs.directories")

local paths = { 
    dir = dirs.cache .. "emoji/",

    json_file = dirs.config .. "lib/gemoji/db/emoji.json"
}

paths.bin = paths.dir .. "emoji.bin"

return paths
