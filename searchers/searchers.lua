-- Submodule searcher is not loaded at this point, so we need to use the path from the main directory

return {
    require("searchers/alias"),
    require("searchers/defaultlib"),
    require("searchers/submodule")
}