----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
----------------------------------------------------------

-- {{{ Grab environment
local pairs = pairs
local tonumber = tonumber
local tostring = tostring
local table = { insert = table.insert }
local math = {
    pow = math.pow,
    floor = math.floor
}
local string = {
    sub = string.sub,
    gsub = string.gsub,
    find = string.find
}
-- }}}


-- Helpers: provides helper functions for vicious widgets
module("vicious.helpers")


-- {{{ Helper functions
-- {{{ Format a string with args
function format(format, args)
    -- TODO: Find a more efficient way to do this

    -- Format a string
    for var, val in pairs(args) do
        format = string.gsub(format, "$"..var, val)
    end

    -- Return formatted string
    return format
end
-- }}}

-- {{{ Padd a number to a minimum amount of digits
function padd(number, padding)
    s = tostring(number)

    if padding == nil then
        return s
    end

    for i=1, padding do
        if math.floor(number/math.pow(10,(i-1))) == 0 then
            s = "0"..s
        end
    end

    if number == 0 then
        s = s:sub(2)
    end

    return s
end
-- }}}

-- {{{ Convert amount of bytes to string
function bytes_to_string(bytes, sec, padding)
    if bytes == nil or tonumber(bytes) == nil then
        return ""
    end

    bytes = tonumber(bytes)

    local signs = {}
    signs[1] = "  b"
    signs[2] = "KiB"
    signs[3] = "MiB"
    signs[4] = "GiB"
    signs[5] = "TiB"

    sign = 1

    while bytes/1024 > 1 and signs[sign+1] ~= nil do
        bytes = bytes/1024
        sign = sign+1
    end

    bytes = bytes*10
    bytes = math.floor(bytes)/10

    if padding then
        bytes = padd(bytes*10, padding+1)
        bytes = bytes:sub(1, bytes:len()-1).."."..bytes:sub(bytes:len())
    end

    if sec then
        return tostring(bytes)..signs[sign].."ps"
    else
        return tostring(bytes)..signs[sign]
    end
end
-- }}}

--{{{ Escape a string
function escape(text)
    if text then
        text = text:gsub("&", "&amp;")
        text = text:gsub("<", "&lt;")
        text = text:gsub(">", "&gt;")
        text = text:gsub("'", "&apos;")
        text = text:gsub("\"", "&quot;")
    end

    return text
end
-- }}}
-- }}}
