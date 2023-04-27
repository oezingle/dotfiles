
-- TODO file that turns arguments into called functions or loaded files what have you

-- every command should be a:
-- function, string, or table that contains a description etc and one of those two to activate
-- the function is passed args but global arg should also be set using getenv
-- a fake require should be used so that code chunks are dynamically reloaded

-- basically it is my goal that CLIs i have already written could just exist within the awesome shell

---@param command string
local function interpret(command)    
    print(command)
end

return interpret