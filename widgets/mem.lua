---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
--  * (c) 2009, Lucas de Vries <lucas@glacicle.com>
---------------------------------------------------

-- {{{ Grab environment
local io = { lines = io.lines }
local setmetatable = setmetatable
local math = { floor = math.floor }
local string = { gmatch = string.gmatch }
-- }}}


-- Mem: provides RAM and Swap usage statistics
module("vicious.widgets.mem")


-- {{{ Memory widget type
local function worker(format)
    local mem = { buf = {}, swp = {} }

    -- Get MEM info
    for line in io.lines("/proc/meminfo") do
        for k, v in string.gmatch(line, "([%a]+):[%s]+([%d]+).+") do
            if     k == "MemTotal"  then mem.total = math.floor(v/1024)
            elseif k == "MemFree"   then mem.buf.f = math.floor(v/1024)
            elseif k == "Buffers"   then mem.buf.b = math.floor(v/1024)
            elseif k == "Cached"    then mem.buf.c = math.floor(v/1024)
            elseif k == "SwapTotal" then mem.swp.t = math.floor(v/1024)
            elseif k == "SwapFree"  then mem.swp.f = math.floor(v/1024)
            end
        end
    end

    -- Calculate memory percentage
    mem.free  = mem.buf.f + mem.buf.b + mem.buf.c
    mem.inuse = mem.total - mem.free
    mem.usep  = math.floor(mem.inuse / mem.total * 100)
    -- Calculate swap percentage
    mem.swp.inuse = mem.swp.t - mem.swp.f
    mem.swp.usep  = math.floor(mem.swp.inuse / mem.swp.t * 100)

    return {mem.usep,     mem.inuse,     mem.total, mem.free,
            mem.swp.usep, mem.swp.inuse, mem.swp.t, mem.swp.f}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
