---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { open = io.open }
local setmetatable = setmetatable
local string = { match = string.match }
-- }}}


-- Thermal: provides temperature levels of ACPI thermal zones
module("vicious.thermal")


-- {{{ Thermal widget type
local function worker(format, thermal_zone)
    -- Get an ACPI thermal zone
    local f = io.open("/proc/acpi/thermal_zone/"..thermal_zone.."/temperature")
    -- Handler for incompetent users
    if not f then return {0} end
    local line = f:read("*line")
    f:close()

    local temperature = tonumber(string.match(line, "[%d]?[%d]?[%d]"))

    return {temperature}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
