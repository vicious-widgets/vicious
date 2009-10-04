---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc.sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local io = { open = io.open }
local setmetatable = setmetatable
-- }}}


-- Thermal: provides temperature levels of ACPI thermal zones
module("vicious.thermal")


-- {{{ Thermal widget type
local function worker(format, thermal_zone)
    -- Get an ACPI thermal zone
    local f = io.open("/proc/acpi/thermal_zone/" .. thermal_zone .. "/temperature")
    -- Handler for incompetent users
    if not f then return {"N/A"} end
    local line = f:read("*line")
    f:close()

    local temperature = line:match("[%d]?[%d]?[%d]")

    return {temperature}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
