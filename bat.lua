----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
----------------------------------------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local table = { insert = table.insert }
-- }}}


-- Bat: provides state, charge, and remaining time for all batteries
module("vicious.bat")


-- {{{ Battery widget type
function worker(format)
    -- Initialise tables
    local battery_info  = {}
    local battery_state = {
        ["charged"]     = "+",
        ["charging"]    = "+",
        ["discharging"] = "-"
    }

    -- Get data from acpitool
    local f = io.popen("acpitool -b")

    -- Format data
    for line in f:lines() do
        -- Check if the battery is present
        if line:match("^[%s]+Battery.*") then
            -- Store state and charge information
            table.insert(battery_info, battery_state[line:match("([%a]*),")])
            table.insert(battery_info, line:match("([%d]?[%d]?[%d])%."))
            -- Store remaining time information if the battery supports it
            table.insert(battery_info, (line:match("%%,%s(.*)") or "/"))
        end
    end
    f:close()

    return battery_info
end
-- }}}
