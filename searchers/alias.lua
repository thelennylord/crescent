-- Searcher function for aliases

return function(name)
    local alias = _G.__ALIASES[name]
    if alias then
        return alias
    end
    return nil, false
end