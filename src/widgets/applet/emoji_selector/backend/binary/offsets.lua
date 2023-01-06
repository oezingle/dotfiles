local struct = {
    UNICODE = 28,
    TAG = 4,
    CATEGORY = 1,
    DESCRIPTION = 44,
    ALIASES = 46
}

local offsets = { struct = struct }

offsets.UNICODE_START = 1
offsets.UNICODE_END = struct.UNICODE

offsets.TAG_START = offsets.UNICODE_END + 1
offsets.TAG_END = struct.TAG + offsets.TAG_START - 1

offsets.CATEGORY_START = offsets.TAG_END + 1
offsets.CATEGORY_END = struct.CATEGORY + offsets.CATEGORY_START - 1

offsets.DESCRIPTION_START = offsets.CATEGORY_END + 1
offsets.DESCRIPTION_END = struct.DESCRIPTION + offsets.DESCRIPTION_START - 1

offsets.ALIASES_START = offsets.DESCRIPTION_END + 1
offsets.ALIASES_END = struct.ALIASES + offsets.ALIASES_START - 1

do
    local size = 0

    for _, v in pairs(struct) do
        size = size + v
    end

    assert(size <= 128)

    struct.total = size
end

return offsets
