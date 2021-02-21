--[[ 
    Virtual file system for crescent
        Handles resolving relative paths into their url form.

    Valid paths for file system are:
       - require('path.to.file')
       - require('path/to/file')
       - require('../../path/to/file')
]]

-- Helper function to parent directory
local function getupperdir(url)
    local rev = url:reverse()
    for i = 1, #rev do
        if rev:byte(i) == string.byte("/") then
            return rev:sub(i+1):reverse()
        end 
    end
end

-- Resolves relative path into its url
local function resolve(path, baseUrl)
    baseUrl = getupperdir(baseUrl)

    -- Test if path uses slashes
    local sep = path:split("/")
    if #sep ~= 1 then
        -- Count the number of back dir
        for _, v in pairs(sep) do
            if v == ".." then
                baseUrl = getupperdir(baseUrl)
            elseif v == '.' then 
                continue
            else
                baseUrl = baseUrl .. '/' .. v
            end
        end

        return baseUrl .. (baseUrl:match("%.%a+$") and "" or ".lua")
    end

    -- Test if path uses dots
    sep = path:split(".")
    if #sep ~= 1 then
        -- Retrive base url, as LUA_PATH is always the main folder the files are stored in and not relative to the file itself
        local path
        for _, v in pairs(_G.__LUAPATH) do
            if baseUrl:sub(1, #v) == v then
                path = v
                break
            end
        end

        return (path or baseUrl) .. '/' .. table.concat(sep, "/") .. ".lua"
    end

    -- Path is just a file
    local ext = path:match("%.%a+$") or ".lua"
    return baseUrl .. '/' .. path .. ext
end

return { resolve = resolve, getupperdir = getupperdir }