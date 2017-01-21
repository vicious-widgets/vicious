-- {{{ Grab environment
local tonumber = tonumber
local setmetatable = setmetatable
local math = { floor = math.floor }
local helpers = require("vicious.helpers")
-- }}}

-- Mem: provides RAM and Swap usage statistics
-- vicious.widgets.mem_freebsd
local mem_freebsd = {}


-- {{{ Memory widget type
local function worker(format)
    local pagesize = tonumber(helpers.sysctl("hw.pagesize"))
    local vm_stats = helpers.sysctl_table("vm.stats.vm")
    local _mem = { buf = {}, total = nil }

    _mem.total = tonumber(vm_stats.v_page_count) * pagesize
    _mem.buf.f = tonumber(vm_stats.v_free_count) * pagesize
    _mem.buf.a = tonumber(vm_stats.v_active_count) * pagesize
    _mem.buf.i = tonumber(vm_stats.v_inactive_count) * pagesize
    _mem.buf.c = tonumber(vm_stats.v_cache_count) * pagesize
    _mem.buf.w = tonumber(vm_stats.v_wire_count) * pagesize

    -- rework into Megabytes
    _mem.total = math.floor(_mem.total/(1024*1024))
    _mem.buf.f = math.floor(_mem.buf.f/(1024*1024))
    _mem.buf.a = math.floor(_mem.buf.a/(1024*1024))
    _mem.buf.i = math.floor(_mem.buf.i/(1024*1024))
    _mem.buf.c = math.floor(_mem.buf.c/(1024*1024))
    _mem.buf.w = math.floor(_mem.buf.w/(1024*1024))

    -- Calculate memory percentage
    _mem.free  = _mem.buf.f + _mem.buf.c
    _mem.inuse = _mem.buf.a + _mem.buf.i
    _mem.wire  = _mem.buf.w
    _mem.bcuse = _mem.total - _mem.buf.f
    _mem.usep  = math.floor(_mem.inuse / _mem.total * 100)
    _mem.inusep= math.floor(_mem.inuse / _mem.total * 100)
    _mem.buffp = math.floor(_mem.bcuse / _mem.total * 100)
    _mem.wirep = math.floor(_mem.wire /  _mem.total * 100)

    -- Get swap states
    local vm = helpers.sysctl_table("vm")
    local _swp = { buf = {}, total = nil }
    
    if tonumber(vm.swap_enabled) == 1 and tonumber(vm.swap_total) > 0 then
        -- Get swap space
        _swp.total = tonumber(vm.swap_total)
        _swp.buf.f = _swp.total - tonumber(vm_stats.v_swapin)
        -- Rework into megabytes
        _swp.total = math.floor(_swp.total/(1024*1024))
        _swp.buf.f = math.floor(_swp.buf.f/(1024*1024))
        -- Calculate percentage
        _swp.inuse = _swp.total - _swp.buf.f
        _swp.usep  = math.floor(_swp.inuse / _swp.total * 100)
    else
         _swp.usep = -1
         _swp.inuse = -1
         _swp.total = -1
         _swp.buf.f = -1
    end

    return { _mem.usep,  _mem.inuse, _mem.total, _mem.free,
             _swp.usep,  _swp.inuse, _swp.total, _swp.buf.f,
             _mem.bcuse, _mem.buffp, _mem.wirep }
end

return setmetatable(mem_freebsd, { __call = function(_, ...) return worker(...) end })
