local function gvariant_ipairs(variant)
    if type(jit) == "table" then
        local function iter(a, i)
            i = i + 1
            local v = a[i]
            if v then
                return i, v
            end
        end

        return function(a)
            return iter, a, 0
        end
    else
        return ipairs(variant)
    end
end

return gvariant_ipairs
