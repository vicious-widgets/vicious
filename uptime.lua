----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
----------------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { open = io.open }
local math = { floor = math.floor }
local helpers = require("vicious.helpers")
-- }}}


-- Uptime: provides system uptime information
module("vicious.uptime")


-- {{{ Uptime widget type
function worker(format, padding)
    -- Get /proc/uptime
    local f = io.open("/proc/uptime")
    local line = f:read()
    f:close()

    -- Format data
    local total_uptime   = math.floor(tonumber(line:match("[%d%.]+")))

    local uptime_days    = math.floor(total_uptime   / (3600 * 24))
    local uptime_hours   = math.floor((total_uptime  % (3600 * 24)) / 3600)
    local uptime_minutes = math.floor(((total_uptime % (3600 * 24)) % 3600) / 60)
    local uptime_seconds = math.floor(((total_uptime % (3600 * 24)) % 3600) % 60)

    if padding then
        if type(padding) == "table" then
            total_uptime   = helpers.padd(total_uptime,   padding[1])
            uptime_days    = helpers.padd(uptime_days,    padding[2])
            uptime_hours   = helpers.padd(uptime_hours,   padding[3])
            uptime_minutes = helpers.padd(uptime_minutes, padding[4])
            uptime_seconds = helpers.padd(uptime_seconds, padding[5])
        else
            total_uptime   = helpers.padd(total_uptime,   padding)
            uptime_days    = helpers.padd(uptime_days,    padding)
            uptime_hours   = helpers.padd(uptime_hours,   padding)
            uptime_minutes = helpers.padd(uptime_minutes, padding)
            uptime_seconds = helpers.padd(uptime_seconds, padding)
        end
    end

    return {total_uptime, uptime_days, uptime_hours, uptime_minutes, uptime_seconds}
end
-- }}}
