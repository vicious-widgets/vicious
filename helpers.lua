---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
--  * (c) 2009, Rémy C. <shikamaru@mandriva.org>
--  * (c) 2009, Benedikt Sauer <filmor@gmail.com>
--  * (c) 2009, Henning Glawe <glaweh@debian.org>
--  * (c) 2009, Lucas de Vries <lucas@glacicle.com>
---------------------------------------------------

-- {{{ Grab environment
local pairs = pairs
local rawget = rawget
local require = require
local tonumber = tonumber
local tostring = tostring
local io = { 
    open = io.open, 
    popen = io.popen 
}
local setmetatable = setmetatable
local getmetatable = getmetatable
local string = {
    upper = string.upper,
    lower = string.lower,
    format = string.format
}
local pcall = pcall
local assert = assert
-- }}}


-- Helpers: provides helper functions for vicious widgets
-- vicious.helpers
local helpers = {}


-- {{{ Variable definitions
local scroller = {}
-- }}}

-- {{{ Helper functions
-- {{{ Determine operating system
local kernel_name
function helpers.getos()
    if kernel_name ~= nil then
      return kernel_name
    end

    local f = io.popen("uname -s")
    kernel_name = string.lower(f:read("*line"))
    f:close()

    return kernel_name
end
-- }}}

-- {{{ Loader of vicious modules
function helpers.wrequire(table, key)
    local ret = rawget(table, key)

    if ret then
        return ret
    end

    local ostable = {
        linux = { "linux", "all" },
        freebsd = { "freebsd", "bsd", "all" }
    }

    local os = ostable[helpers.getos()]
    assert(os, "Vicious: platform not supported: " .. helpers.getos())

    for i = 1, #os do
        local name = table._NAME .. "." .. key .. "_" .. os[i]
        local status, value = pcall(require, name)
        if status then
            ret = value
            break
        end
        not_found_msg = "module '"..name.."' not found"

        -- ugly but there is afaik no other way to check if a module exists
        if value:sub(1, #not_found_msg) ~= not_found_msg then
          -- module found, but different issue -> let's raise the real error
          require(name)
        end
    end

    assert(ret, "Vicious: widget " .. table._NAME .. "." .. key .. " not available for current platform or does not exist")

    return ret
end
-- }}}

-- {{{ Expose path as a Lua table
function helpers.pathtotable(dir)
    return setmetatable({ _path = dir },
        { __index = function(table, index)
            local path = table._path .. '/' .. index
            local f = io.open(path)
            if f then
                local s = f:read("*all")
                f:close()
                if s then
                    return s
                else
                    local o = { _path = path }
                    setmetatable(o, getmetatable(table))
                    return o
                end
            end
        end
    })
end
-- }}}

-- {{{ Format a string with args
function helpers.format(format, args)
    for var, val in pairs(args) do
        format = format:gsub("$" .. (tonumber(var) and var or
            var:gsub("[-+?*]", function(i) return "%"..i end)),
        val)
    end

    return format
end
-- }}}

-- {{{ Format units to one decimal point
function helpers.uformat(array, key, value, unit)
    for u, v in pairs(unit) do
        array["{"..key.."_"..u.."}"] = string.format("%.1f", value/v)
    end

    return array
end
-- }}}

-- {{{ Escape a string
function helpers.escape(text)
    local xml_entities = {
        ["\""] = "&quot;",
        ["&"]  = "&amp;",
        ["'"]  = "&apos;",
        ["<"]  = "&lt;",
        [">"]  = "&gt;"
    }

    return text and text:gsub("[\"&'<>]", xml_entities)
end
-- }}}

-- {{{ Escape a string for safe usage on the command line
function helpers.shellquote(arg)
   local s = tostring(arg)
   if s == nil then return "" end
   -- use single quotes, and put single quotes into double quotes
   -- the string $'b is then quoted as '$'"'"'b'"'"'
   return "'" .. s:gsub("'", "'\"'\"'") .. "'"
end
-- }}}

-- {{{ Capitalize a string
function helpers.capitalize(text)
    return text and text:gsub("([%w])([%w]*)", function(c, s)
        return string.upper(c) .. s
    end)
end
-- }}}

-- {{{ Truncate a string
function helpers.truncate(text, maxlen)
    local txtlen = text:len()

    if txtlen > maxlen then
        text = text:sub(1, maxlen - 3) .. "..."
    end

    return text
end
-- }}}

-- {{{ Scroll through a string
function helpers.scroll(text, maxlen, widget)
    if not scroller[widget] then
        scroller[widget] = { i = 1, d = true }
    end

    local txtlen = text:len()
    local state  = scroller[widget]

    if txtlen > maxlen then
        if state.d then
            text = text:sub(state.i, state.i + maxlen) .. "..."
            state.i = state.i + 3

            if maxlen + state.i >= txtlen then
                state.d = false
            end
        else
            text = "..." .. text:sub(state.i, state.i + maxlen)
            state.i = state.i - 3

            if state.i <= 1 then
                state.d = true
            end
        end
    end

    return text
end
-- }}}

-- {{{ Return result from one sysctl variable as string
function helpers.sysctl(path)
    local fd = io.popen("sysctl -n " .. helpers.shellquote(path))

    if not fd then
        return
    end

    local ret = fd:read()

    fd:close()

    return ret
end
--  }}}

-- {{{ Return result from multiple sysctl variables as table
function helpers.sysctl_table(syspath)
    return setmetatable({ _path = syspath },
        { __index = function(table, index)
            local path = "sysctl -n " .. helpers.shellquote(table._path .. "." .. index)
            local f = io.popen(path)
            if f then
                local s = f:read("*all")
                f:close()
                if select(2, s:gsub("\n", "\n")) > 1 then
                    local o = { _path = path}
                    setmetatable(o, getmetatable(table))
                    return o
                else
                    return s
                end
            end
        end
    })
end
-- }}}

return helpers

-- }}}
