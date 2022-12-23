local json = require("lib.json")
local fs = require("src.util.fs")
local class = require("lib.30log")
local has_awesome = require("lib.test").has_awesome

local cache_dir = fs.dirs.cache

---@alias SerializerFunction fun(table: table): string

---@alias DeserializerFunction fun(contents: string): table

---@alias MutatorFunction fun(input: any): table

---@alias DemutatorFunction fun(input: table): any

---@class SaveState
---@field has_awesome boolean static readonly. if the file is running under AwesomeWM
---@field serializer SerializerFunction
---@field deserializer DeserializerFunction
---@field mutator MutatorFunction
---@field contents table the data to serialize
---@field path string
---@operator call:SaveState
local SaveState = class("SaveState", {
    has_awesome = has_awesome()
})

---@class SaveStateOptArgs
---@field serializer SerializerFunction?
---@field deserializer DeserializerFunction?
---@field mutator MutatorFunction?
---@field demutator DemutatorFunction?
---@field default any?

--- Easily interact with JSON save states
---@param filename string a .json file name. folders do not work
---@param opts SaveStateOptArgs?
function SaveState:init(filename, opts)
    self.path = cache_dir .. filename

    opts = opts or {}

    if opts.serializer then
        self:set_serializer(opts.serializer)
    else
        self:set_serializer(json.encode)
    end

    if opts.deserializer then
        self:set_deserializer(opts.deserializer)
    else
        self:set_deserializer(json.decode)
    end

    if opts.mutator then
        self:set_mutator(opts.mutator)
    else
        self:set_mutator(function(i)
            return i
        end)
    end

    if opts.demutator then
        self:set_demutator(opts.demutator)
    else
        self:set_demutator(function(i)
            return i
        end)
    end

    self.contents = opts.default or {}

    self:load_state()

    -- TODO option to fill keys in the default that don't exist in the file

    self:enable_signal()
end

--- Get the data deserialized and demutated from the file
---@return table contents
function SaveState:get_contents()
    return self.contents
end

--- Setters
do
    -- de/serializer
    do
        --- Set the serializer function for the SaveState
        ---@param serializer SerializerFunction
        ---@return SaveState self for convenience
        function SaveState:set_serializer(serializer)
            self.serializer = serializer

            return self
        end

        --- Set the deserializer function for the SaveState
        ---@param deserializer DeserializerFunction
        ---@return SaveState self for convenience
        function SaveState:set_deserializer(deserializer)
            self.deserializer = deserializer

            return self
        end
    end

    -- de/mutator
    do
        --- Set the mutator function for the SaveState
        ---@param mutator MutatorFunction
        ---@return SaveState self for convenience
        function SaveState:set_mutator(mutator)
            self.mutator = mutator

            return self
        end

        --- Set the demutator function for the SaveState
        ---@param demutator DemutatorFunction
        ---@return SaveState self for convenience
        function SaveState:set_demutator(demutator)
            self.demutator = demutator

            return self
        end
    end
end

-- save/load state
do
    --- Load the saved state
    ---@private
    function SaveState:load_state()
        local contents = fs.read(self.path)

        if not contents then
            return
        end

        self.contents = self.demutator(self.deserializer(contents))
    end

    --- Save self.contents to disk
    ---@private
    function SaveState:save_state()
        local contents = self.serializer(self.mutator(self.contents))

        fs.write(self.path, contents)
    end
end

--- Save self.contents to disk
---@return SaveState self
function SaveState:save()
    --- acts an an alias
    self:save_state()

    return self
end

--- Connect AwesomeWM exit signal
---@private
function SaveState:enable_signal()
    if self.has_awesome then
        awesome.connect_signal("exit", function()
            self:save_state()
        end)
    end
end

return SaveState
