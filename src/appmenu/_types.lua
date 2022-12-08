---@meta

---@alias MenuInfo { service: string, path: string }

---@class MenuItem
---@field activate fun(self: MenuItem)
---@field label string
---@field get_children fun(self: MenuItem, callback: fun(children: any[]))
---@field MENU_TYPE string
