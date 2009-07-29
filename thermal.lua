----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
----------------------------------------------------------

-- {{{ Grab environment
local io = { open = io.open }
-- }}}


-- Thermal: provides temperature levels of ACPI thermal zones
module("vicious.thermal")


-- {{{ Thermal widget type
function worker(format, thermal_zone)
    -- Get thermal zone
    local f = io.open("/proc/acpi/thermal_zone/" .. thermal_zone .. "/temperature")
    local line = f:read()
    f:close()

    -- Get temperature data
    local temperature = line:match("[%d]?[%d]?[%d]")

    return {temperature}
end
-- }}}
