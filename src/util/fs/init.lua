
local fs = {
    ls = require("src.util.fs.list").ls,
    mkdir = require("src.util.fs.mkdir").mkdir,
    mkdir_p = require("src.util.fs.mkdir_p"),
    cp = require("src.util.fs.cp"),
    is_dir = require("src.util.fs.is_dir"),
    exists = require("src.util.fs.exists"),

    read = require("src.util.fs.read"),
    write = require("src.util.fs.write"),

    pwd = require("src.util.fs.pwd").pwd,
    is_windows = require("src.util.fs.is_windows"),
}

return fs