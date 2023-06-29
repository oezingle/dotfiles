
local XMLTransformer = require("lib.widgey_old.XMLTransformer")

local wibox = {
    container = {},
    layout = {
        flex = {}
    },
    widget = setmetatable({}, { __call = function () return 'hi' end })
}

local doc = XMLTransformer():set_document([[
<wibox.widget>
    <wibox.container.margin margins="{5}">
        <!-- A comment -->
        <Vertical spacing="{5}">
            Example of dynamics {get_status_value()}

            And multiline!
        </Vertical>
    </wibox.container.margin>
</wibox.widget>
]]):run()

print(doc)


--[[
-- TODO relying on get_locals could be quite slow - can I somehow query variable names?
local b = "hi"

local fn, err = load("local a = b; print('a=', a)", nil, nil, setmetatable(get_locals(), { __index = _G }))

if not fn then
    print("err", err)
else
    fn()
end
]]

--[[
#doc type=document root=table: 0x564024777810
    #text parent=table: 0x564024782250 type=text value=    
    wibox.container.margin parent=table: 0x564024782250 el=table: 0x564024774230 type=element attr=table: 0x564024774270
            #text parent=table: 0x564024777810 type=text value=
    
            #comment parent=table: 0x564024777810 type=comment value= A comment 
            #text parent=table: 0x564024777810 type=text value=
    
            wibox.layout.flex.vertical parent=table: 0x564024777810 el=table: 0x564024786e40 type=element attr=table: 0x564024786e80
                    #text parent=table: 0x564024786cf0 type=text value=
        Example of dynamics {get_status_value()}
    
            #text parent=table: 0x564024777810 type=text value=
]]

--[[
local function recurse_xml_node (node, depth)
    depth = depth or 0 

    local space = ("\t"):rep(depth)

    local key_values = {}

    for k, v in pairs(node) do
        if k ~= "name" and k ~= "kids" then
            table.insert(key_values, tostring(k) .. "=" .. tostring(v))
        end 
    end

    print(space .. node.name .. " " .. table.concat(key_values, " "))

    for _, v in pairs(node.kids or {}) do
        recurse_xml_node(v, depth + 1)
    end
end

recurse_xml_node(doc)
]]