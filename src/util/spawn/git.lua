
-- This file can't use spawn helpers at all, as they require submodules that may not exist.

local git = {
    _cache = {}
}

function git.has ()
    if git._cache.has then
        return git._cache.has
    end

    local handle, err = io.popen("which git")

    if not handle then
        git._cache.has = false
        return false
    end

    local content = handle:read("a")

    if content:match("which: no") then
        git._cache.has = false
        return false
    end

    git._cache.has = true
    return true
end

function git.is ()
    if not git.has() then
        return false
    end

    if git._cache.is then
        return git._cache.is
    end

    local handle, err = io.popen("git status 2>&1", "r")

    if not handle then
        -- TODO error message
        
        git._cache.is = false
        return false
    end

    local response = handle:read("a")

    if response:match("fatal") then
        git._cache.is = false
        return false
    end

    git._cache.is = true
    return true
end

function git.init_submodules ()
    if git.is() then
        print("Pulling submodules. This may take a moment.")

        io.popen("git submodule update --init --recursive")
    end
end

return git