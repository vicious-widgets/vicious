-- disk I/O widget type for GNU/Linux
-- Copyright (C) 2011  Jörg T. <jthalheim@gmail.com>
-- Copyright (C) 2017  Elric Milon <whirm@gmx.com>
-- Copyright (C) 2017  mutlusun <mutlusun@github.com>
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
local pairs = pairs
local io = { lines = io.lines }
local os = { time = os.time, difftime = os.difftime }

local helpers = require"vicious.helpers"
-- }}}

-- Initialize function tables
local disk_usage = {}
local disk_stats = {}
local disk_time  = 0
-- Constant definitions
local unit = { ["s"] = 1, ["kb"] = 2, ["mb"] = 2048 }
local time_unit = { ["ms"] = 1, ["s"] = 1000 }

-- {{{ Disk I/O widget type
return helpers.setcall(function ()
    local disk_lines = {}

    for line in io.lines("/proc/diskstats") do
        local device, read, write, iotime =
            -- Linux kernel documentation: Documentation/iostats.txt
            line:match"([^%s]+) %d+ %d+ (%d+) %d+ %d+ %d+ (%d+) %d+ %d+ (%d+)"
        disk_lines[device] = { read, write, iotime }
    end

    local time = os.time()
    local interval = os.difftime(time, disk_time)
    if interval == 0 then interval = 1 end

    for device, stats in pairs(disk_lines) do
        -- Avoid insane values on startup
        local last_stats = disk_stats[device] or stats

        -- Check for overflows and counter resets (> 2^32)
        if stats[1] < last_stats[1] or stats[2] < last_stats[2] then
            for i = 1,3 do last_stats[i] = stats[i] end
        end

        -- Diskstats are absolute, substract our last reading
        -- * divide by timediff because we don't know the timer value
        local read  = (stats[1] - last_stats[1]) / interval
        local write = (stats[2] - last_stats[2]) / interval
        local iotime = (stats[3] - last_stats[3]) / interval

        -- Calculate and store I/O
        helpers.uformat(disk_usage, device.." read",  read,  unit)
        helpers.uformat(disk_usage, device.." write", write, unit)
        helpers.uformat(disk_usage, device.." total", read + write, unit)
        helpers.uformat(disk_usage, device.." iotime", iotime, time_unit)
    end

    disk_time  = time
    disk_stats = disk_lines

    return disk_usage
end)
-- }}}
