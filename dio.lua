---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local ipairs = ipairs
local setmetatable = setmetatable
local math = { floor = math.floor }
local table = { insert = table.insert }
local helpers = require("vicious.helpers")
local string = {
    gmatch = string.gmatch,
    format = string.format
}
-- }}}


-- Disk I/O: provides I/O statistics for requested storage devices
module("vicious.dio")


-- Initialise function tables
local disk_usage = {}
local disk_total = {}

-- {{{ Helper functions
local function uformat(array, key, value)
    array["{"..key.."_s}"]  = string.format("%.1f", value)
    array["{"..key.."_kb}"] = string.format("%.1f", value/2)
    array["{"..key.."_mb}"] = string.format("%.1f", value/2/1024)
    return array
end
-- }}}

-- {{{ Disk I/O widget type
local function worker(format, disk)
    local disk_lines = {}
    local disk_stats = helpers.pathtotable("/sys/block/" .. disk)

    if disk_stats.stat then
        local match = string.gmatch(disk_stats.stat, "[%s]+([%d]+)")
        for i = 1, 11 do -- Store disk stats
            table.insert(disk_lines, match())
        end
    end

    -- Ensure tables are initialized correctly
    local diff_total  = {}
    while #disk_total < #disk_lines do
        table.insert(disk_total, 0)
    end

    for i, v in ipairs(disk_lines) do
        -- Diskstats are absolute, substract our last reading
        diff_total[i] = v - disk_total[i]

        -- Store totals
        disk_total[i] = v
    end

    -- Calculate and store I/O
    uformat(disk_usage, "read",  diff_total[3])
    uformat(disk_usage, "write", diff_total[7])
    uformat(disk_usage, "total", diff_total[7] + diff_total[3])

    return disk_usage
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
