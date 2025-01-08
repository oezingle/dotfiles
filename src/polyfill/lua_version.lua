
local version = {
    ---@type string | "Lua"
    distribution = _VERSION:match("^(.-)%s[%d%.]+$"),

    ---@type string | "5.4" | "5.3" | "5.2" | "5.1" | "5.0" | "4.0"
    version = _VERSION:match("^.-%s([%d%.]+)$"),

    ---@type number?
    version_major = tonumber(_VERSION:match("^.-%s(%d)[%d%.]+$")),
    ---@type number?
    version_minor = tonumber(_VERSION:match("^.-%s%d%.(%d)[%d%.]*$")),
    ---@type number?
    version_patch = tonumber(_VERSION:match("^.-%s%d%.%d%.(%d)$")),

    ---@diagnostic disable-next-line:undefined-global
    is_jit = not not jit
}

return version