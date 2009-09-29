---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc.sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local io = { open = io.open }
local setmetatable = setmetatable
-- }}}


-- Load: provides system load averages for the past 1, 5, and 15 minutes
module("vicious.load")


-- {{{ Load widget type
local function worker(format)
    -- Get load averages
    local f = io.open('/proc/loadavg')
    local line = f:read("*line")
    f:close()

    local avg1, avg5, avg15 = 
        line:match("([%d]*%.[%d]*)%s([%d]*%.[%d]*)%s([%d]*%.[%d]*)")

    return {avg1, avg5, avg15}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
