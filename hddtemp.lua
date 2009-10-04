---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc.sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { match = string.match }
-- }}}


-- Hddtemp: provides hard drive temperatures using the hddtemp daemon
module("vicious.hddtemp")


-- {{{ HDD Temperature widget type
local function worker(format, port)
    -- Fallback to default hddtemp port
    if port == nil then port = 7634 end

    -- Get info from the hddtemp daemon
    local f = io.popen("curl --connect-timeout 1 -fsm 3 telnet://127.0.0.1:" .. port)
    local hdd_temp = {}

    for line in f:lines() do
        local disk, temp = string.match(line, "|([%/%a]+)|.*|([%d]+)|[CF]+|")

        if disk ~= nil and temp ~= nil then
            hdd_temp["{"..disk.."}"] = temp
        end
    end
    f:close()

    return hdd_temp
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
