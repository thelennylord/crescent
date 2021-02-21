-- Searcher for importing default lua libs

return function(name)
    if name == "math" then
        return math
    elseif name == "string" then
        return string
    elseif name == "table" then
        return table
    elseif name == "bit32" then
        return bit32
    elseif name == "os" then
        return os
    end
    return nil, false
end