_G.__MODULEPOINTER = {}
_G.__LOADED = {}
_G.__LUAPATH = {}

local virtualfs

-- Helper functions
local function fetchfile(url)
    local success, res = pcall(game.HttpGetAsync, game, url)
    if not success then
        if res == "HTTP 404 (NOT FOUND)" then
            return nil, string.format("attempt to require a non-existent module '%s'", url)
        else
            return nil, res
        end
    end

    local module, err = loadstring(res)
    
    -- Module has compile time errors?
    if not module then
        return nil, string.format("module '%s' contains malformed lua. This may be due to the module not being compatible with Lua 5.1 or LuaU.\n%s", url, err)
    end

    _G.__LUAPATH[#_G.__LUAPATH+1] = virtualfs.getupperdir(url)
    _G.__MODULEPOINTER[tostring(module)] = url
    return module, nil
end

local function nrequire(path)
    -- The main function for loading in a module

    -- This is the zeroth searcher function and cannot be removed
    -- Is it a url?
    if path:match("^http://") or path:match("^https://") then
        -- Is the function cached?
        local cached = _G.__LOADED[path]
        if cached then return cached end
        
        local func, err = fetchfile(path)
        if err then
            return error(err)
        end

        func = func()
        _G.__LOADED[path] = func
        return func
    end

    -- Path is not a url, let the searchers do their jobs
    for i = 1, #_G.__SEARCHERS do
        local searcher = _G.__SEARCHERS[i]

        local ret, fatal = searcher(path)
        local typeofret = type(ret)
        
        -- Did the searcher return a fatal error?
        if fatal then
            return error(string.format("attempt to require '%s' failed. A searcher has returned a fatal error, which has been given below.\n%s"), path, ret)
        end

        if typeofret == "function" then
            -- Assume function is not in cache as its the searcher's job to do so
            return ret
        elseif typeofret == "string" then
            -- Searcher has returned the url of the module
            -- We should fetch the the text and load in the module
            local cached = _G.__LOADED[ret]
            if cached then return cached end
            
            if not _G.__SILENT then print(string.format("Download %s", ret)) end

            local func, err = fetchfile(ret)
            if err then
                return error(err)
            end

            func = func()
            _G.__ALIASES[path] = ret
            _G.__LOADED[ret] = func
            return func
        elseif typeofret ~= "nil" then
            return ret
        end
    end

    -- All the searchers failed to find the module, throw an error letting the user know
    return error(string.format("attempt to require a non-existent module '%s'", path))
end

-- Hook require function
local old;
old = hookfunction(require, function(arg)
    if type(arg) == "string" then
        return nrequire(arg)
    end
    return old(arg)
end)

-- The coreload searcher, tests for whether the required module is part of the crescent core
table.insert(_G.__SEARCHERS, function(path)
    local cached = _G.__LOADED[path]
    if cached then return cached end
    
    local baseUrl = _G.__DEV and "http://localhost:4507/" or "https://raw.githubusercontent.com/thelennylord/crescent/main/"
    local url = baseUrl .. path .. ".lua"
    
    if _G.__LOADED["virtualfs"] then            
        local func, err = fetchfile(url)
        if err then
            return nil, false
        end

        func = func()
        _G.__LOADED[url] = func
        return func
    else
        local success, res = pcall(game.HttpGetAsync, game, url)
        if not success then
            return nil, false
        end

        local module, err = loadstring(res)
        if not module then
            return err, true
        end

        local func = module()
        _G.__MODULEPOINTER[tostring(module)] = url
        _G.__LOADED[path] = func
        return func, false
    end
    
end)

-- Import virtualfs
virtualfs = require("virtualfs")

-- Add seachers to the table
local searchers = require("searchers/searchers")
for i = 1, #searchers do
    table.insert(_G.__SEARCHERS, searchers[i])
end

-- Move the coreloader searcher to last
local coreload = _G.__SEARCHERS[1]
table.remove(_G.__SEARCHERS, 1)
table.insert(_G.__SEARCHERS, coreload)

_G.__READY = true
if _G.__DEV then
    print("crescent has been successfully loaded (using DEV environment).")
else
    print("crescent has been successfully loaded.")
end