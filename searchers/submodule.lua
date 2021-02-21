-- Searcher for returning url of module if it the parent module was imported using an url

local virtualfs = require("virtualfs")

return function(path)
    local url
    local level = 1
    while true do
        local info = debug.getinfo(level, "f")

        -- Call does not come from an imported module?
        if not info then
            return nil, false
        end
        local ptr = _G.__MODULEPOINTER[tostring(info.func)]
        if not ptr then 
            level = level + 1
        else
            url = ptr
            break
        end
    end
    
    return virtualfs.resolve(path, url), nil
end