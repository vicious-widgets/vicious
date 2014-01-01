---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { gmatch = string.gmatch }
local helpers = require("vicious.helpers")
-- }}}


-- Hddtemp: provides hard drive temperatures using the hddtemp daemon
-- vicious.widgets.hddtemp
local hddtemp = {}


-- {{{ HDD Temperature widget type
local function worker(format, warg)
    -- Fallback to default hddtemp port
    if warg == nil then warg = 7634 end

    local hdd_temp = {} -- Get info from the hddtemp daemon
    local quoted = helpers.shellquote(warg)
    local f = io.popen("echo | curl --connect-timeout 1 -fsm 3 telnet://127.0.0.1:"..quoted)

    for line in f:lines() do
        for d, t in string.gmatch(line, "|([%/%a%d]+)|.-|([%d]+)|[CF]+|") do
            hdd_temp["{"..d.."}"] = tonumber(t)
        end
    end
    f:close()

    return hdd_temp
end
-- }}}

return setmetatable(hddtemp, { __call = function(_, ...) return worker(...) end })
