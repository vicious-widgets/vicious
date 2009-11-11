---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local setmetatable = setmetatable
local helpers = require("vicious.helpers")
-- }}}


-- Thermal: provides temperature levels of ACPI thermal zones
module("vicious.thermal")


-- {{{ Thermal widget type
local function worker(format, thermal_zone)
    local thermal = helpers.pathtotable("/sys/class/thermal/"..thermal_zone)

    -- Get ACPI thermal zone
    if thermal.temp then
        return {thermal.temp / 1000}
    end

    return {0}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
