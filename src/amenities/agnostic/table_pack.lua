---@nospec busted doesn't allow version switching, so testing version-agnostic
---functionality for correctness is impossible.

--- I chose to call this an amenity as opposed to a polyfill as it isn't
--- require()'d - though polyfills in JavaScript often work silently, I would
--- rather not pollute global scope.

---@diagnostic disable-next-line:duplicate-set-field
table.pack = function (...)
    --- Used to feature backwards compatibility with table.n, but this broke much!
    -- n=select('#',...), 
    return {...}
end

---@diagnostic disable-next-line:deprecated
table.unpack = table.unpack or unpack