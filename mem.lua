---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc@sysphere.org>
--  * (c) 2008, Lucas de Vries <lucas@glacicle.com>
---------------------------------------------------

-- {{{ Grab environment
local io = { open = io.open }
local setmetatable = setmetatable
local math = { floor = math.floor }
local string = { match = string.match }
-- }}}


-- Mem: provides RAM and Swap usage statistics
module("vicious.mem")


-- {{{ Memory widget type
local function worker(format)
    -- Get meminfo
    local f = io.open("/proc/meminfo")
    local mem  = { buf = {}, swp = {}, }

    for line in f:lines() do
        if string.match(line, "^MemTotal.*") then
            mem.total = math.floor(string.match(line, "([%d]+)")/1024)
        elseif string.match(line, "^MemFree.*") then
            mem.buf.f = math.floor(string.match(line, "([%d]+)")/1024)
        elseif string.match(line, "^Buffers.*") then
            mem.buf.b = math.floor(string.match(line, "([%d]+)")/1024)
        elseif string.match(line, "^Cached.*") then
            mem.buf.c = math.floor(string.match(line, "([%d]+)")/1024)
        -- Get swap stats while we are at it
        elseif string.match(line, "^SwapTotal.*") then
            mem.swp.total = math.floor(string.match(line, "([%d]+)")/1024)
        elseif string.match(line, "^SwapFree.*") then
            mem.swp.free = math.floor(string.match(line, "([%d]+)")/1024)
        end
    end
    f:close()

    -- Calculate percentage
    mem.free  = mem.buf.f + mem.buf.b + mem.buf.c
    mem.inuse = mem.total - mem.free
    mem.usep  = math.floor(mem.inuse / mem.total * 100)
    -- Calculate swap percentage
    mem.swp.inuse = mem.swp.total - mem.swp.free
    mem.swp.usep  = math.floor(mem.swp.inuse / mem.swp.total * 100)

    return {mem.usep,     mem.inuse,     mem.total,     mem.free,
            mem.swp.usep, mem.swp.inuse, mem.swp.total, mem.swp.free}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
