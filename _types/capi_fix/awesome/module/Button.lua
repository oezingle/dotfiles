---@meta

---@alias ButtonSignal "press" | "property::button" | "property::modifiers" | "release"

---@class CButtonModule
---@field instances fun(): integer Get the number of instances. This includes removed buttons
---@field set_index_miss_handler fun(cb: function) Set a __index metamethod for all button instances. 
---@field set_newindex_miss_handler fun(cb: function) Set a __newindex metamethod for all button instances. 

---@alias ButtonModule CButtonModule | ClassSignalAble<ButtonSignal>