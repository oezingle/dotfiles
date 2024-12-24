https://lunarmodules.github.io/busted/#asserts

# Extending Your Own Assertions

Add in your own assertions to reuse commonly written code. You can register error message keys for both positive (is) and negative (is_not) cases for multilingual compatibility as well ("en" by default.)

```lua
local say = require("say")

local function has_property(state, arguments)
  local has_key = false

  if not type(arguments[1]) == "table" or #arguments ~= 2 then
    return false
  end

  for key, value in pairs(arguments[1]) do
    if key == arguments[2] then
      has_key = true
    end
  end

  return has_key
end

say:set("assertion.has_property.positive", "Expected %s \nto have property: %s")
say:set("assertion.has_property.negative", "Expected %s \nto not have property: %s")
assert:register("assertion", "has_property", has_property, "assertion.has_property.positive", "assertion.has_property.negative")

describe("my table", function()
  it("has a name property", function()
    assert.has_property({ name = "Jack" }, "name")
  end)
end)
```