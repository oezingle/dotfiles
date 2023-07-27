
local test = require("lib.test")

local unpad = require("lib.widgey.unpad")
local xml_gsub = require("lib.widgey.XMLTransformer.xml_gsub")

local xml = unpad([[
    <component prop="{{ value }}" prop2={{ value }}>
        <subcomponent prop2="{"value"}">
            <child1 />
        </subcomponent>

        <child2 prop3={value} add={"testing"} />

        <child3 prop4={"value"} />
    </component>
]])

local xml_good = unpad([[
    <component prop="{{ value }}" prop2="{{ value }}">
        <subcomponent prop2="{\"value\"}">
            <child1 />
        </subcomponent>

        <child2 prop3="{value}" add="{\"testing\"}" />

        <child3 prop4="{\"value\"}" />
    </component>
]])

test.suite("xml_gsub",
    test.assert(xml_gsub(xml) == xml_good)
)