---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc.sysphere.org>
--  * (c) Wicked, Lucas de Vries
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { open = io.open }
local setmetatable = setmetatable
local math = { floor = math.floor }
-- }}}


-- Uptime: provides system uptime information
module("vicious.uptime")


-- {{{ Uptime widget type
local function worker(format)
    -- Get /proc/uptime
    local f = io.open("/proc/uptime")
    local line = f:read("*line")
    f:close()

    local total_uptime   = math.floor(tonumber(line:match("[%d%.]+")))
    local uptime_days    = math.floor(total_uptime   / (3600 * 24))
    local uptime_hours   = math.floor((total_uptime  % (3600 * 24)) / 3600)
    local uptime_minutes = math.floor(((total_uptime % (3600 * 24)) % 3600) / 60)
    local uptime_seconds = math.floor(((total_uptime % (3600 * 24)) % 3600) % 60)

    return {total_uptime, uptime_days, uptime_hours, uptime_minutes, uptime_seconds}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
