---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2011, Jörg T. <jthalheim@gmail.com>
---------------------------------------------------

-- {{{ Grab environment
local pairs = pairs
local io = { lines = io.lines }
local setmetatable = setmetatable
local string = { match = string.match }
local helpers = require("vicious.helpers")
local os = {
    time = os.time,
    difftime = os.difftime
}
-- }}}


-- Disk I/O: provides I/O statistics for requested storage devices
-- vicious.widgets.dio
local dio_linux = {}


-- Initialize function tables
local disk_usage = {}
local disk_stats = {}
local disk_time  = 0
-- Constant definitions
local unit = { ["s"] = 1, ["kb"] = 2, ["mb"] = 2048 }
local time_unit = { ["ms"] = 1, ["s"] = 1000 }

-- {{{ Disk I/O widget type
local function worker(format)
    local disk_lines = {}

    for line in io.lines("/proc/diskstats") do
        local device, read, write, iotime =
            -- Linux kernel documentation: Documentation/iostats.txt
          string.match(line, "([^%s]+) %d+ %d+ (%d+) %d+ %d+ %d+ (%d+) %d+ %d+ (%d+)")
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
            last_stats[1], last_stats[2], last_stats[3] = stats[1], stats[2], stats[3]
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
end
-- }}}

return setmetatable(dio_linux, { __call = function(_, ...) return worker(...) end })
