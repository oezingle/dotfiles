---@meta

---@alias TagSignal "request::select" | "tagged" | "untagged" | "property::urgent" | "property::urgent_count" | "request::screen" | "removal-pending"

---@class CTag
---@field name string Tag name. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag.name)
---@field selected boolean True if the tag is selected to be viewed. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag.selected)
---@field activated boolean True if the tag is active and can be used. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag.activated)
---@field index integer The tag index. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag.index)
---@field screen Screen The tag screen. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag.screen)
---@field master_width_factor number The tag master width factor. 0.0 - 1.0. [Link](https://awesomewm.org/doc/api/classes/tag.master_width_factor)
---@field layout Layout The tag client layout. [Link](https://awesomewm.org/doc/api/classes/tag.layout)
---@field layouts Layout[] The (proposed) list of available layouts for this tag. [Link](https://awesomewm.org/doc/api/classes/tag.layouts)
---@field volatile boolean Define if the tag must be deleted when the last client is untagged. [Link](https://awesomewm.org/doc/api/classes/tag.volatile)
---@field gap number The gap (spacing, also called useless_gap) between clients. [Link](https://awesomewm.org/doc/api/classes/tag.gap)
---@field gap_single_client boolean Enable gaps for a single client. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag.gap_single_client)
---@field master_fill_policy "expand" | "master_width_factor" Set size fill policy for the master client(s). [Link](https://awesomewm.org/doc/api/classes/tag.html#tag.master_fill_policy)
---@field master_count integer Set the number of master windows. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag.master_count)
---@field icon string|Surface Set the tag icon. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag.icon)
---@field column_count number Set the number of columns. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag.column_count)
---@field clients InstanceGetterOrSetter<CTag, Client[]> Get or set the clients attached to this tag. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag:clients)
---@field swap fun(self: CTag, t: CTag) Swap 2 tags. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag:swap)
---@field delete fun(self: CTag) Delete a tag. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag:delete)
---@field view_only fun(self: CTag) View only a tag. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag:view_only)

---@alias Tag CTag | InstanceSignalAble<TagSignal>

---@class TagModule
---@field instances fun(): integer Get the number of instances. This includes removed tags
