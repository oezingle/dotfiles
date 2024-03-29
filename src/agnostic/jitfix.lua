
jit = jit or nil

if jit then
    -- Add a loader for module.init, becaues luajit doesn't by default

    ---@diagnostic disable-next-line:deprecated
    table.insert(package.searchers or package.loaders, function (library)
        if not library:match("%.init$") then
            local path = package.searchpath(library .. ".init", package.path)
            
            if path then
                return function () 
                    return require(library .. ".init")
                end                
            end
        end
    end)
end