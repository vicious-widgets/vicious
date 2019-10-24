-- contrib/dio_linux.lua
-- Copyright (C) 2010, Adrian C. <anrxc@sysphere.org>
-- Copyright (C) 2017  Jörg Thalheim <joerg@higgsboson.tk>
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
local ipairs = ipairs
local setmetatable = setmetatable
local table = { insert = table.insert }
local string = { gmatch = string.gmatch }
local helpers = require("vicious.helpers")
-- }}}


-- Disk I/O: provides I/O statistics for requested storage devices
-- vicious.contrib.dio
local dio_linux = {}


-- Initialize function tables
local disk_usage = {}
local disk_total = {}
-- Variable definitions
local unit = { ["s"] = 1, ["kb"] = 2, ["mb"] = 2048 }

-- {{{ Disk I/O widget type
local function worker(format, disk)
    if not disk then return end

    local disk_lines = { [disk] = {} }
    local disk_stats = helpers.pathtotable("/sys/block/" .. disk)

    if disk_stats.stat then
        local match = string.gmatch(disk_stats.stat, "[%s]+([%d]+)")
        for i = 1, 11 do -- Store disk stats
            table.insert(disk_lines[disk], match())
        end
    end

    -- Ensure tables are initialized correctly
    local diff_total = { [disk] = {} }
    if not disk_total[disk] then
        disk_usage[disk] = {}
        disk_total[disk] = {}

        while #disk_total[disk] < #disk_lines[disk] do
            table.insert(disk_total[disk], 0)
        end
    end

    for i, v in ipairs(disk_lines[disk]) do
        -- Diskstats are absolute, substract our last reading
        diff_total[disk][i] = v - disk_total[disk][i]

        -- Store totals
        disk_total[disk][i] = v
    end

    -- Calculate and store I/O
    helpers.uformat(disk_usage[disk], "read",  diff_total[disk][3], unit)
    helpers.uformat(disk_usage[disk], "write", diff_total[disk][7], unit)
    helpers.uformat(disk_usage[disk], "total", diff_total[disk][7] + diff_total[disk][3], unit)

    -- Store I/O scheduler
    if disk_stats.queue and disk_stats.queue.scheduler then
        disk_usage[disk]["{sched}"] = string.gmatch(disk_stats.queue.scheduler, "%[([%a]+)%]")
    end

    return disk_usage[disk]
end
-- }}}

return setmetatable(dio_linux, { __call = function(_, ...) return worker(...) end })
