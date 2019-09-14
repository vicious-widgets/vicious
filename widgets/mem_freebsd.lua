-- RAM and swap usage widget type for FreeBSD
-- Copyright (C) 2017-2019  mutlusun <mutlusun@github.com>
-- Copyright (C) 2018  Andreas Geisenhainer <psycorama@datenhalde.de>
-- Copyright (C) 2019  Nguyễn Gia Phong <vn.mcsinyx@gmail.com>
--
-- This file is part of Vicious.
--
-- Vicious is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as
-- published by the Free Software Foundation, either version 2 of the
-- License, or (at your option) any later version.
--
-- Vicious is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with Vicious.  If not, see <https://www.gnu.org/licenses/>.

-- {{{ Grab environment
local tonumber = tonumber
local math = { floor = math.floor }
local string = {
    match = string.match,
    gmatch = string.gmatch,
    find = string.find
}

local helpers = require("vicious.helpers")
local spawn = require("vicious.spawn")
-- }}}

-- Mem: provides RAM and Swap usage statistics
-- vicious.widgets.mem_freebsd
local mem_freebsd = {}


-- {{{ Memory widget type
function mem_freebsd.async(format, warg, callback)
    helpers.sysctl_async({ "hw.pagesize",
                           "vm.stats.vm",
                           "vm.swap_total",
                           "vm.swap_enabled" },
                         function(ret)

        local pgsz = tonumber(ret["hw.pagesize"])
        local _mem = { buf = {}, total = nil }

        -- Get memory space in bytes
        _mem.total = tonumber(ret["vm.stats.vm.v_page_count"]) * pgsz
        _mem.buf.free = tonumber(ret["vm.stats.vm.v_free_count"]) * pgsz
        _mem.buf.laundry = tonumber(ret["vm.stats.vm.v_laundry_count"]) * pgsz
        _mem.buf.cache = tonumber(ret["vm.stats.vm.v_cache_count"]) * pgsz
        _mem.buf.wired = tonumber(ret["vm.stats.vm.v_wire_count"]) * pgsz

        -- Rework into megabytes
        _mem.total = math.floor(_mem.total/1048576)
        _mem.buf.free = math.floor(_mem.buf.free/1048576)
        _mem.buf.laundry = math.floor(_mem.buf.laundry/1048576)
        _mem.buf.cache = math.floor(_mem.buf.cache/1048576)
        _mem.buf.wired = math.floor(_mem.buf.wired/1048576)

        -- Calculate memory percentage
        _mem.free  = _mem.buf.free + _mem.buf.cache
        -- used memory basically consists of active+inactive+wired
        _mem.inuse = _mem.total - _mem.free
        _mem.notfreeable = _mem.inuse - _mem.buf.laundry
        _mem.wire  = _mem.buf.wired

        _mem.usep  = math.floor(_mem.inuse / _mem.total * 100)
        _mem.wirep = math.floor(_mem.wire / _mem.total * 100)
        _mem.notfreeablep = math.floor(_mem.notfreeable / _mem.total * 100)

        -- Get swap states
        local vm_swap_total = tonumber(ret["vm.swap_total"])
        local vm_swap_enabled = tonumber(ret["vm.swap_enabled"])
        local _swp = { buf = {}, total = nil }

        if vm_swap_enabled == 1 and vm_swap_total > 0 then
            -- Initialise variables
            _swp.usep = 0
            _swp.inuse = 0
            _swp.total = 0
            _swp.buf.free = 0

            -- Read output of swapinfo in Mbytes (from async function call)
            -- Read content and sum up
            spawn.with_line_callback("swapinfo -m", {
                stdout = function(line)
                    if not string.find(line, "Device") then
                        local ltotal, lused, lfree = string.match(
                            line, "%s+([%d]+)%s+([%d]+)%s+([%d]+)")
                        -- Add swap space in Mbytes
                        _swp.total = _swp.total + tonumber(ltotal)
                        _swp.inuse = _swp.inuse + tonumber(lused)
                        _swp.buf.free = _swp.buf.free + tonumber(lfree)
                    end
                end,
                output_done = function()
                    print(_swp.inuse, _swp.total)
                    _swp.usep = math.floor(_swp.inuse / _swp.total * 100)
                    callback({ _mem.usep,
                               _mem.inuse,
                               _mem.total,
                               _mem.free,
                               _swp.usep,
                               _swp.inuse,
                               _swp.total,
                               _swp.buf.free,
                               _mem.wirep,
                               _mem.wire,
                               _mem.notfreeablep,
                               _mem.notfreeable })
                end
            })
        else
             _swp.usep = -1
             _swp.inuse = -1
             _swp.total = -1
             _swp.buf.free = -1
             callback({ _mem.usep,
                        _mem.inuse,
                        _mem.total,
                        _mem.free,
                        _swp.usep,
                        _swp.inuse,
                        _swp.total,
                        _swp.buf.free,
                        _mem.wirep,
                        _mem.wire,
                        _mem.notfreeablep,
                        _mem.notfreeable })
        end
    end)
end
-- }}}

return helpers.setasyncall(mem_freebsd)
