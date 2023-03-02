local fs = require("src.util.fs")

--- Get the system's set language.
local function get_lang()
    --[[
        uses the LANG environment variable.
        this is something like en_US.UTF-8,
        so we grab up until the underscore.

        if LANG is unset, getenv returns nil
        and the fallback 'en' is used
    ]]
    local lang = os.getenv("LANG")

    if lang then
        local prefix = string.match(lang, "[^_]+")


        return prefix
    else
        return "en"
    end
end

---@class Translation
---@field battery BatteryTranslation

---@class BatteryTranslation
---@field state BatteryStateTranslation
---@field warning BatteryWarningsTranslation
---@field to_full string
---@field to_empty string
---@field health string

---@class BatteryStateTranslation
---@field unknown string
---@field charging string
---@field discharging string
---@field empty string
---@field fully_charged string
---@field pending_charge string
---@field pending_discharge string
---@field last string

---@class BatteryWarningsTranslation
---@field action string
---@field critical string
---@field message string

local translation_dir = fs.directories.translation

local unset_translation = translation_dir .. "unset.json"

-- TODO error for all unset keys

--- Get the translation table for the user
---@return Translation
local function get_translations()
    local lang = get_lang()

    local lang_file = translation_dir .. lang .. ".json"

    local unset_lang = setmetatable(fs.json.load(unset_translation), {
        __index = function ()
            return "JSON_NOT_SET"
        end
    })

    if fs.exists(lang_file) then
        local user_lang = fs.json.load(lang_file)

        return setmetatable(user_lang, {
            __index = unset_lang
        })
    else
        return unset_lang
    end
end

return get_translations()
