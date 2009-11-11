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

-- {{{ Disk I/O widget type
local function worker(format, disk)
    local disk_lines = {}
    local disk_stats = setmetatable(
        { _path = "/sys/block/" .. disk },
        helpers.pathtotable
    )

    if disk_stats.stat then
        local match = string.gmatch(disk_stats.stat, "[%s]+([%d]+)")
        for i = 1, 11 do -- Store disk stats
            table.insert(disk_lines, match())
        end
    end

    -- Ensure tables are initialized correctly
    while #disk_total < #disk_lines do
        table.insert(disk_total, 0)
    end

    local diff_total  = {}

    for i, v in ipairs(disk_lines) do
        -- Diskstats are absolute, substract our last reading
        diff_total[i] = v - disk_total[i]

        -- Store totals
        disk_total[i] = v
    end

    -- Calculate I/O
    disk_usage["{raw}"] = diff_total[7] + diff_total[3]
    -- Divide "sectors read" by 2 and 1024 to get KB and MB
    disk_usage["{kb}"] = string.format("%.1f", math.floor(diff_total[7] + diff_total[3])/2)
    disk_usage["{mb}"] = string.format("%.1f", math.floor(diff_total[7] + diff_total[3])/1024)

    return disk_usage
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
