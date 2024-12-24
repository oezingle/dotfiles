
# Lua as a self-modifying language

The basic idea here is to create a language extension that allows the creation
of further language extensions in Lua. This document will only include some
motivating examples for the time being.

## The `generate` keyword
A possible solution is a `generate` keyword that means 'spit out lua code here'.
Any valid lua can follow this keyword, which will essentially be printf'd into
the scope surrounding the call. Think of it as a super-return, containing the
context of the outer space. However, the `generate` keyword would not break from
the function, instead acting as `yield` does in JavaScript, or the Lua
`coroutine.yield()`

## static functions
Like defining a variable local, we could declare it static. This does not
guarantee that some action like calling a static function would result in an
unrolling - its arguments must also be static. static variables throw errors on
modification, similar to the hasty and useless lua 5.4 implementation of consts.
Importantly, any static variable that is not a function must be serializable.

## Examples

### Autoglob
In some cases, a programmer would like to load all the files in a certain
directory. In this example, we load multiple lua modules from a directory.

```lua
local static function ls (path)
    local files = fs.list(path)

    -- we trust the programmer to make this cast to static 
    return static files
end

local static function generate_modules ()
    local modules = {}

    -- Any literal is static!
    for _, file in ipairs(ls("./modules")) do
        local module_name = file:match("([^/\\]+)%.lua^")

        -- Generate keyword here is important - this isn't a call to loadfile(file), but rather any unrolling of generate_modules() should return require()
        modules[module_name] = generate loadfile(file)
    end

    return static modules
end

return generate_modules()
```

This would transpile to..
```lua
-- Functions are preserved as vanilla lua to allow non-static calls
local function ls (path)
    local files = fs.list(path)

    return files
end

local function generate_modules ()
    local modules = {}

    for _, file in ipairs(ls("./modules")) do
        local module_name = file:match("([^/\\]+)%.lua^")

        modules[module_name] = loadfile(file)
    end

    return modules
end

--- This scope was static, so we get generated code
return {
    module_a = loadfile("./modules/module_a.lua"),
    module_b = loadfile("./modules/module_b.lua"),
}
```

## language feature categories
- assignment
- operation
- reference
Is that all?

"operation" is vague - difference between a mutator (or "yielding operation") and branch control?

variables indexed by arbitrary values, as tables in lua.

return could be an assignment to a variable (reference) of some sort of unique name (but you can get it in lang.internal.return_address in module 'lang' or whatever) that is literally like return register + jump to return address

import -> set variable (name or module->default) 

maybe "return value as <varname>

a variable name is the highest parent of a reference. this includes assignment

an assignment just creates a reference with an attached name (essentially?)
but an assignment can also be viewed as a return to previous

allow querying callee name, value, etc. This comes at low cost because of recursive JIT compilation

operation can be thought of "return callee <op> arg"

## compiler: is_constant (expression)

I don't think it can be just assignments - operations such as string concat or 
