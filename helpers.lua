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
local io = { open = io.open }
local setmetatable = setmetatable
local getmetatable = getmetatable
local string = {
    upper = string.upper,
    format = string.format
}
-- }}}


-- Helpers: provides helper functions for vicious widgets
-- vicious.helpers
local helpers = {}


-- {{{ Variable definitions
local scroller = {}
-- }}}

-- {{{ Helper functions
-- {{{ Loader of vicious modules
function helpers.wrequire(table, key)
    local module = rawget(table, key)
    return module or require(table._NAME .. "." .. key)
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

return helpers

-- }}}
