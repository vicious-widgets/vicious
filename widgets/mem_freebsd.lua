----------------------------------------------
-- Mem: provides RAM and Swap usage statistics
----------------------------------------------

-- Grab environment --
local tonumber = tonumber
local setmetatable = setmetatable
local math = { floor = math.floor }
local helpers = require("vicious.helpers")

local mem_freebsd = {}

-- Memory widget type --
local function worker(format)
    local hw = helpers.sysctl_table("hw")
    local vm_stats = helpers.sysctl_table("vm.stats.vm")
    local _mem = { buf = {}, total = nil }

    _mem.total = tonumber(vm_stats.v_page_count) * tonumber(hw.pagesize)
    _mem.buf.f = tonumber(vm_stats.v_free_count) * tonumber(hw.pagesize)
    _mem.buf.a = tonumber(vm_stats.v_active_count) * tonumber(hw.pagesize)
    _mem.buf.i = tonumber(vm_stats.v_inactive_count) * tonumber(hw.pagesize)
    _mem.buf.c = tonumber(vm_stats.v_cache_count) * tonumber(hw.pagesize)
    _mem.buf.w = tonumber(vm_stats.v_wire_count) * tonumber(hw.pagesize)

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

    -- @todo: expand to get swap states
    -- local vm = helpers.sysctl_table("vm")
    -- local _swp = { buf = {}, total = nil }

    -- if vm.swap_enable == 1 and vm.swap_total > 0 then
    --     _swp_.usep =
    --     _swp.total = tonumber(vm.swap_total) * tonumber(hw.pagesize)
    --     _swp_inuse =
    --     _swp_free  =
    -- end

    -- use default values until i get some swap
    local _swp = { buf = {}, total = nil }
    _swp_usep = -1
    _swp.inuse = -1
    _swp.free  = -1
    _swp.total = -1

    return { _mem.usep,  _mem.inuse, _mem.total, _mem.free,
             _swp.usep,  _swp.inuse, _swp.total, _swp.free,
             _mem.bcuse, _mem.buffp, _mem.wirep }
end

return setmetatable(mem_freebsd, { __call = function(_, ...) return worker(...) end })
