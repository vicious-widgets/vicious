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
local io = { open = io.open, popen = io.popen }
local setmetatable = setmetatable
local getmetatable = getmetatable
local string = {
    upper = string.upper,
    lower = string.lower,
    format = string.format,
    match = string.match,
    find = string.find,
}
local table = { concat = table.concat }
local pcall = pcall
local assert = assert
local spawn = require("vicious.spawn")
-- }}}


-- Helpers: provides helper functions for vicious widgets
-- vicious.helpers
local helpers = {}

-- {{{ Constants definitions
local OS_UNSUPPORTED_ERR = "Vicious: platform not supported: %s"
local NOT_FOUND_MSG = "module '%s' not found"
local NOT_FOUND_ERR = [[
Vicious: %s is not available for the current platform or does not exist]]
-- }}}

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
function helpers.wrequire(collection, key)
    local ret = rawget(collection, key)

    if ret then
        return ret
    end

    local ostable = {
        linux = { "linux", "all" },
        freebsd = { "freebsd", "bsd", "all" },
        openbsd = { "openbsd", "bsd", "all" }
    }

    local platform = ostable[helpers.getos()]
    assert(platform, OS_UNSUPPORTED_ERR:format(helpers.getos()))

    local basename = collection._NAME .. '.' .. key
    for i = 1, #platform do
        local name = basename .. '_' .. platform[i]
        local status, value = pcall(require, name)
        if status then
            ret = value
            break
        end

        -- This is ugly but AFAWK there is no other way to check for
        -- the type of error. If other error get caught, raise it.
        if value:find(NOT_FOUND_MSG:format(name), 1, true) == nil then
            require(name)
        end
    end

    assert(ret, NOT_FOUND_ERR:format(basename))
    return ret
end
-- }}}

-- {{{ Set __call metamethod to widget type table having async key
function helpers.setasyncall(wtype)
    local function worker(format, warg)
        local ret
        wtype.async(format, warg, function (data) ret = data end)
        while ret == nil do end
        return ret
    end
    local metatable = { __call = function (_, ...) return worker(...) end }
    return setmetatable(wtype, metatable)
end
-- }}}

-- {{{ Expose path as a Lua table
function helpers.pathtotable(dir)
    return setmetatable({ _path = dir },
        { __index = function(self, index)
            local path = self._path .. '/' .. index
            local f = io.open(path)
            if f then
                local s = f:read("*all")
                f:close()
                if s then
                    return s
                else
                    local o = { _path = path }
                    setmetatable(o, getmetatable(self))
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

-- {{{ Parse output of sysctl command calling the `parse` function
function helpers.sysctl_async(path_table, parse)
    local ret = {}
    local path = {}

    for i=1,#path_table do
        path[i] = helpers.shellquote(path_table[i])
    end

    path = table.concat(path, " ")

    spawn.with_line_callback("sysctl " .. path, {
        stdout = function(line)
	    local separators = {
	       openbsd = "=",
	       linux = " = ",
	       freebsd = ": "
	    }

	    local pattern = "(.+)%s(.+)"
	    pattern = pattern:format(separators[helpers.getos()])

            if not string.find(line, "sysctl: unknown oid") then
                local key, value = string.match(line, pattern)
                ret[key] = value
            end
        end,
        output_done = function() parse(ret) end
    })
end
--  }}}

return helpers

-- }}}
