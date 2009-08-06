----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
----------------------------------------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local setmetatable = setmetatable
-- }}}


-- Hddtemp: provides hard drive temperatures using the hddtemp daemon
module("vicious.hddtemp")


-- {{{ HDD Temperature widget type
function worker(format, port)
    -- Fallback to default hddtemp port
    if port == nil then port = 7634 end

    -- Get info from the hddtemp daemon
    local f = io.popen("curl --max-time 3 -f -s telnet://127.0.0.1:" .. port)
    local hdd_temp = {}

    -- Get temperature data
    for line in f:lines() do
        local disk, temp = line:match("|([%/%a]+)|.*|([%d]+)|[CF]+|")

        if disk ~= nil and temp ~= nil then
            hdd_temp["{"..disk.."}"] = temp
        end
    end
    f:close()

    return hdd_temp
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
