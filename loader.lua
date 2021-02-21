--[[
    Loader file for crescent
        This script should be called when loading in crescent.
    
    Example script of loading in crescent:

    ```lua
    local crescent = loadstring(game:HttpGet("https://raw.githubusercontent.com/thelennylord/crescent/main/loader.lua"))()

    -- Add extra aliases
    crescent.add_alias({
        somealias = "https://example.com/path/to/file.lua"
    })

    -- Start crescent
    crescent.init()
    ```
]]

-- Initialise global variables required for the loader
_G.__ALIASES = {}
_G.__SEARCHERS = {}
_G.__READY = false

-- Does the user's executor support hookfunction?
if not hookfunction then
    return error("Your executor does not support hookfunction, which is required for crescent to function properly.")
end

local baseurl
if _G.__DEV then
    baseurl = "http://localhost:4507/"
else
    baseurl = "https://raw.githubusercontent.com/thelennylord/crescent/main/"
end

local init = loadstring(game:HttpGet(baseurl .. "core.lua"))

-- Function for adding aliases
-- Accepts a key-value table of aliases, where the key is the alias and the value is the url
local function add_alias(alias_table)
    for k, v in pairs(alias_table) do
        _G.__ALIASES[k] = v
        if _G.__DEV then print(string.format("Added alias %s -> %s", k, v)) end
    end
end

-- Load aliases from crescent/alias.toml
-- Check if user has the needed functions to read/write files
if readfile then
    local success, file = pcall(readfile, "crescent.config.toml")
    if success then    
        -- A fork of lua-toml is being used to read toml files
        -- Author: https://github.com/pocomane
        -- Repo: https://github.com/pocomane/lua-toml
        local toml = loadstring(game:HttpGet("https://raw.githubusercontent.com/pocomane/lua-toml/master/toml.lua"))()    
        local aliases = toml.parse(file)
        add_alias(aliases.aliases)
    end
end

-- Function for adding searchers
-- Accepts a list of searcher functions
-- You should probably call this function after crescent has loaded as calling it 
-- before would result in the custom searcher having the most priority than the core ones
-- TODO: Add documentation for searchers
local function add_searcher(searchers)
    if #searchers == 0 then return end
    for i = 1, #searchers do
        table.insert(_G.__SEARCHERS, searchers[i])
    end
end

-- Return functions to the user
return {
    add_searcher = add_searcher,
    add_alias = add_alias,
    init = init
}