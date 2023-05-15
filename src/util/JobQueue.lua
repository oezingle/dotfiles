
local LinkedList = require("src.util.LinkedList")
local class = require("lib.30log")
local Promise = require("src.util.Promise")

---@class JobQueue.Job : Log.BaseFunctions
---@operator call:JobQueue.Job
---@field starter fun(): Promise
---@field identifier any
---@field hooks function[]
---@field started boolean
---@field promise Promise
local Job = class("JobQueue.Job")

---@param starter fun(): Promise
---@param identifier any
function Job:init(starter, identifier)    
    self.starter = starter

    self.identifier = identifier

    self.hooks = {}

    self.started = false
end

---@param identifier any
---@return boolean
function Job:match(identifier)
    return self.identifier and self.identifier == identifier
end 

--- Add a hook for when the job completes
---@param hook function
---@return self self for convienience
function Job:add_hook(hook)
    if self.started then
        self.promise:after(function (...)
            hook(...)

            return ...
        end)
    else
        table.insert(self.hooks, hook)
    end

    return self
end

--- Start the job
function Job:start()
    if self.started then
        return self.promise
    end

    self.promise = self.starter()
    
    self.started = true

    for _, hook in ipairs(self.hooks) do
        self.promise:after(function (...)
            hook(...)

            return ...
        end)
    end

    return self.promise
end


---@class JobQueue : Log.BaseFunctions
---@operator call:JobQueue
---@field list LinkedList<JobQueue.Job>
---@field autostart boolean
local JobQueue = class("JobQueue")

function JobQueue:init()
    self.list = LinkedList()

    self.autostart = true
end

---@generic T
---@param starter fun(): Promise<`T`>
---@param identifier any
---@return Promise<T>
function JobQueue:add(starter, identifier)
    for _, job in self.list:iterator() do
        if job:match(identifier) then
            return Promise(function (res)
                job:add_hook(res)
            end)
        end
    end

    local job = Job(starter, identifier)

    local promise = Promise(function (res)
        job:add_hook(function (...)
            -- The first element should be the only one started
            self:move_to_next()
            
            res(...)
        end)
    end)

    self.list:enqueue(job)

    -- start first queue job if not started
    if self.autostart then
        self:start()        
    end

    return promise
end

function JobQueue:start()
    local job = self.list:first()

    if not job then
        return Promise.resolve()
    end

    return job:start()
end

function JobQueue:move_to_next()
    self.list:dequeue()

    self:start()
end

function JobQueue:disable_autostart()
    self.autostart = false
end

return JobQueue