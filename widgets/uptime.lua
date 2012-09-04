---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
--  * (c) 2009, Lucas de Vries <lucas@glacicle.com>
---------------------------------------------------

-- {{{ Grab environment
local setmetatable = setmetatable
local math = { floor = math.floor }
local string = { match = string.match }
local helpers = require("vicious.helpers")
-- }}}


-- Uptime: provides system uptime and load information
-- vicious.widgets.uptime
local uptime = {}


-- {{{ Uptime widget type
local function worker(format)
    local proc = helpers.pathtotable("/proc")

    -- Get system uptime
    local up_t = math.floor(string.match(proc.uptime, "[%d]+"))
    local up_d = math.floor(up_t   / (3600 * 24))
    local up_h = math.floor((up_t  % (3600 * 24)) / 3600)
    local up_m = math.floor(((up_t % (3600 * 24)) % 3600) / 60)

    local l1, l5, l15 = -- Get load averages for past 1, 5 and 15 minutes
      string.match(proc.loadavg, "([%d%.]+)[%s]([%d%.]+)[%s]([%d%.]+)")
    return {up_d, up_h, up_m, l1, l5, l15}
end
-- }}}

return setmetatable(uptime, { __call = function(_, ...) return worker(...) end })
