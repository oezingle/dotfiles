
local test = require("lib.test")

local parse_xml_value = require("lib.widgey_old.parse_xml_value")

test.suite("parse_xml_value", 
    test.assert(parse_xml_value("string") == "[[string]]", "Simple string"),
    test.assert(parse_xml_value("{0}") == "0", "Integer"),
    test.assert(parse_xml_value("{0.1}") == "0.1", "Decimal"),
    test.assert(parse_xml_value("{function () print('hi') end}") == "function () print('hi') end", "Function")
)