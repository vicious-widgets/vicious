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
-- vicious.widgets.mem
local mem = {}


-- {{{ Memory widget type
local function worker(format)
    local _mem = { buf = {}, swp = {} }

    -- Get MEM info
    for line in io.lines("/proc/meminfo") do
        for k, v in string.gmatch(line, "([%a]+):[%s]+([%d]+).+") do
            if     k == "MemTotal"  then _mem.total = math.floor(v/1024)
            elseif k == "MemFree"   then _mem.buf.f = math.floor(v/1024)
            elseif k == "Buffers"   then _mem.buf.b = math.floor(v/1024)
            elseif k == "Cached"    then _mem.buf.c = math.floor(v/1024)
            elseif k == "SwapTotal" then _mem.swp.t = math.floor(v/1024)
            elseif k == "SwapFree"  then _mem.swp.f = math.floor(v/1024)
            end
        end
    end

    -- Calculate memory percentage
    _mem.free  = _mem.buf.f + _mem.buf.b + _mem.buf.c
    _mem.inuse = _mem.total - _mem.free
    _mem.bcuse = _mem.total - _mem.buf.f
    _mem.usep  = math.floor(_mem.inuse / _mem.total * 100)
    -- Calculate swap percentage
    _mem.swp.inuse = _mem.swp.t - _mem.swp.f
    _mem.swp.usep  = math.floor(_mem.swp.inuse / _mem.swp.t * 100)

    return {_mem.usep,     _mem.inuse,     _mem.total, _mem.free,
            _mem.swp.usep, _mem.swp.inuse, _mem.swp.t, _mem.swp.f,
            _mem.bcuse }
end
-- }}}

return setmetatable(mem, { __call = function(_, ...) return worker(...) end })
