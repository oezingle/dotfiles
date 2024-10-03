---@meta

-- ---@diagnostic disable:lowercase-global

---@alias Awesome.Gears.Surface table
---@alias Awesome.Gears.Shape function
---@alias Awesome.Struts { right: integer, left: integer, top: integer, bottom: integer }
---@alias Awesome.Key table
---@alias Awesome.Wibox table
---@alias Awesome.Wibox.Widget table
---@alias Awesome.Layout table|function

---@type Awesome
awesome = awesome

---@type Awesome.ClientModule
client = client or {}

---@type Awesome.ScreenModule
screen = screen or {}

---@type Awesome.Root
root = root or {}

---@type Awesome.TagModule
tag = tag or {}

---@type Awesome.Mouse
mouse        = mouse or {}

---@type Awesome.Mousegrabber
mousegrabber = mousegrabber or {}

---@type Awesome.ButtonModule
button       = button or {}

local UnixSignal = require("lib.awesome_capi.awesome.module.Awesome").UnixSignal
local Mouse = require("lib.awesome_capi.awesome.module.Mouse")

return {
    UnixSignal = UnixSignal,
    Mouse = Mouse
}