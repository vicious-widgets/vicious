---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc.sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { open = io.open }
local setmetatable = setmetatable
local string = { match = string.match }
-- }}}


-- Load: provides system load averages for the past 1, 5, and 15 minutes
module("vicious.load")


-- {{{ Load widget type
local function worker(format)
    local f = io.open('/proc/loadavg')
    local line = f:read("*line")
    f:close()

    local l1, l5, l15 =  -- Get load averages for past 1, 5 and 15 minutes
      string.match(line, "([%d]*%.[%d]*)%s([%d]*%.[%d]*)%s([%d]*%.[%d]*)")

    return {tonumber(l1), tonumber(l5), tonumber(l15)}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
