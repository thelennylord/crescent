# Crescent

A Luau package loader for requiring lua scripts from the internet. Inspired by [Deno](https://deno.land)'s import statement.

## Requirements
You need a Roblox executor for this script to work.
Your executor needs to support the following functions:
- hookfunction
- readfile (optional)

## Installation
Add the following script to your executor's autoexec folder to get started.
```lua
local crescent = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/thelennylord/crescent/main/loader.lua"))()

crescent.init()
```

## Features
- Caches required script locally per session, so it can be loaded quicky upon next require.
- Supports lua scripts which depend on other local lua scripts.
- Supports aliases, so you don't have to use the full url.

## Usage
Whenever you wish to require a lua script by its url, simply enter the url as the first argument of the `require` function.<br/>
Example:
```lua
local re = require("https://raw.githubusercontent.com/o080o/reLua/master/re.lua")

-- Now re.lua has been loaded and you are ready to use it
local regex = re.compile("r(e*)gex?")
local res = regex:execute("reeeeeeeeeegex")
print(res)
```

## Adding aliases
Instead of requiring a script by its url, you may define an alias for the same. An alias allows you to load a script by providing its alias, rather than the script's url. Aliases can be added by two ways.
### Defining aliases in crescent.config.toml
**NOTE:** Your executor needs to have the `readfile` function. If not, please see the second method.<br/><br>
Aliases can be defined in the `crescent.config.toml` file, which should be located in your executor's `workspace` folder. If `crescent.config.toml` doesn't exist, you need to create it. Example of defining aliases is given below:
```toml
[aliases]
myscript = "https://example.com/path/to/file.lua"
myOtherScript = "https://example.com/path/to/another/file.lua"
```
### Defining aliases upon initialisation
Aliases can be added when crescent is about to load. This is done by editing the script which loads crescent. The crescent loader script returns three functions, one of them being the `add_alias` function. This function is used to define aliases. Example of adding aliases using the `add_alias` function is given below:
```lua
local crescent = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/thelennylord/crescent/main/loader.lua"))()

-- Define aliases here
crescent.add_alias({
    somealias = "https://example.com/path/to/file.lua",
    anotherAlias = "https://example.com/path/to/another/file.lua"
})

-- Start crescent
crescent.init()
```
Aliases can also be added after crescent has loaded through the aforementioned function.
### Example
```lua
-- Suppose you've defined an alias for 'https://raw.githubusercontent.com/o080o/reLua/master/re.lua', which is 're'.
-- You can then require the above script by its alias.
local re = require("re")
```

# Local development
crescent currently uses itself to load its core modules. Due to this, developing locally might be a hassle. However we have implemented a development environment to make things easier.<br>
To enable the development environment, you need the following prerequisite:
- [Deno](https://deno.land)

To enable the development environment, make sure to set `_G.__DEV = true` before loading in crescent as this tells crescent to use the local server to fetch the core modules. The local server is a simple file server which uses Deno. Run the `dev.bat` file to start the local server and now load `loader.lua` using the local server's url. Your script should look something like this:
```lua
_G.__DEV = true
local crescent = loadstring(game:HttpGetAsync("http://localhost:4507/loader.lua"))()
-- Remaining code...
```

# LICENSE
[MIT](https://github.com/thelennylord/crescent/blob/main/LICENSE)