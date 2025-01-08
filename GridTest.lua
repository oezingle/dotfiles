
local LuaX = require("lib.LuaX")

local Grid = require("src.components.base.Grid")
local GridItem = require("src.components.base.GridItem")

local Text = require("src.components.base.Text")
local Background = require("src.components.base.Background")

local GridBlock = LuaX(function (props)
    return [[
        <GridItem 
            row={props.row} column={props.column}
            width={props.width} height={props.height}
        >
            <Background color="#00ff00">
                <Text>{props.id}</Text>
            </Background>
        </GridItem>
    ]]
end)

local GridTest= LuaX(function ()
    return [[
        <Grid rows={5} columns={5}>
            <GridBlock column={3} id="One" />

            <GridBlock column={2} row={4} id="Two" />
            
            <GridBlock column={2} width={3} id="Three" />
        </Grid>
    ]]
end)

return GridTest