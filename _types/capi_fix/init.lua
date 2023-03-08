---@meta

---@diagnostic disable: lowercase-global

---@alias Surface table
---@alias GearsShape function
---@alias Struts { right: integer, left: integer, top: integer, bottom: integer }
---@alias Button table
---@alias Key table
---@alias Wibox table
---@alias Widget table
---@alias Layout table|function

---@type Awesome
awesome = awesome or {}

---@type ClientModule | ClassSignalAble<ClientSignal>
client = client or {}

---@type ScreenModule | ClassSignalAble<ScreenSignal> | fun(): Screen https://awesomewm.org/doc/api/classes/screen.html
screen = screen or {}

---@type Root
root = root or {}

---@type TagModule | ClassSignalAble<TagSignal>
tag = tag or {}

---@type Mouse
mouse        = mouse or {}


mousegrabber = mousegrabber or {}
button       = button or {}
