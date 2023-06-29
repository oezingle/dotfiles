local XMLTransformer = require("lib.widgey_old.XMLTransformer")

---@param content string
local function transform(content)
    local xmlpattern = "(self:xml%(%[%[(.-)%]%]%))"

    content = content:gsub(xmlpattern, function (_, xml)
        local transformed = XMLTransformer()
            :set_static(true) -- magic sauce
            :set_document(xml)
            :run()

        -- TODO FIXME AAAAH VERSION DEPENDENT CODE EEEEK
        transformed = transformed:gsub("%{self%.props%.children%}", "table.unpack(self.props.children)")

        return transformed
    end)

    print(content)

    return content
end

-- https://mark1626.github.io/posts/2021/04/21/lua-module-loader/
-- Adapted from lua 5.2

-- TODO also enable a compile-in-place version
-- TODO .x.lua loader transpiles to .lua, spits out .lua, 
-- TODO calls require() for you on the newly transpiled code. 
-- TODO also checks mtime to make sure recompile not needed

---@diagnostic disable-next-line:deprecated
table.insert(package.searchers or package.loaders, function(modulename)
    local modulepath = string.gsub(modulename, "%.", "/")
    for path in string.gmatch("./?.x.lua;./?/init.x.lua", "([^;]+)") do
        local filename = string.gsub(path, "%?", modulepath)
        local file = io.open(filename, "rb")
        if file then
            local content = assert(file:read("*a"))
            local transformed_file = transform(content)

            -- TODO bad assert! bad!
            return assert(load(transformed_file, modulename))
        end
    end

    -- TODO lame ass error message
    return "Unable to load file " .. modulename
end)
