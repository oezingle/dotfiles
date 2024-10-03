#!/usr/bin/luajit

local argparse = require("lib.argparse")

local function main()
    local parser = argparse()

    parser:flag("verbose")

    local arguments = parser:parse()

    require("src.amenities.init")

    if not arguments.verbose then
        log.level = "error"
    end

    local prompt = require("src.cli.init")

    prompt.run()
end

main()
