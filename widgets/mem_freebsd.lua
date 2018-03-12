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

    -- Get memory space in bytes
    _mem.total = tonumber(vm_stats.v_page_count) * pagesize
    _mem.buf.free = tonumber(vm_stats.v_free_count) * pagesize
    _mem.buf.laundry = tonumber(vm_stats.v_laundry_count) * pagesize
    _mem.buf.cache = tonumber(vm_stats.v_cache_count) * pagesize
    _mem.buf.wired = tonumber(vm_stats.v_wire_count) * pagesize

    -- Rework into megabytes
    _mem.total = math.floor(_mem.total/1048576)
    _mem.buf.free = math.floor(_mem.buf.free/1048576)
    _mem.buf.laundry = math.floor(_mem.buf.laundry/1048576)
    _mem.buf.cache = math.floor(_mem.buf.cache/1048576)
    _mem.buf.wired = math.floor(_mem.buf.wired/1048576)

    -- Calculate memory percentage
    _mem.free  = _mem.buf.free + _mem.buf.cache + _mem.buf.laundry
    -- used memory basically consists of active+inactive+wired
    _mem.inuse = _mem.total - _mem.free
    _mem.wire  = _mem.buf.wired
    _mem.usep  = math.floor(_mem.inuse / _mem.total * 100)
    _mem.wirep = math.floor(_mem.wire / _mem.total * 100)

    -- Get swap states
    local vm_swap_total = tonumber(helpers.sysctl("vm.swap_total"))
    local vm_swap_enabled = tonumber(helpers.sysctl("vm.swap_enabled"))
    local _swp = { buf = {}, total = nil }

    if vm_swap_enabled == 1 and vm_swap_total > 0 then
        -- Get swap space in bytes
        _swp.total = vm_swap_total
        _swp.buf.f = _swp.total - tonumber(vm_stats.v_swapin)
        -- Rework into megabytes
        _swp.total = math.floor(_swp.total/1048576)
        _swp.buf.f = math.floor(_swp.buf.f/1048576)
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
             _mem.wirep, _mem.wire }
end

return setmetatable(mem_freebsd, { __call = function(_, ...) return worker(...) end })
