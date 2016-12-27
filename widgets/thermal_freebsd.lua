---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local setmetatable = setmetatable
local string = { match = string.match }
local helpers = require("vicious.helpers")
-- }}}


-- Thermal: provides temperature levels of ACPI and coretemp thermal zones
-- vicious.widgets.thermal
local thermal_freebsd = {}


-- {{{ Thermal widget type
local function worker(format, warg)
    if not warg then return end

    local temp = helpers.sysctl("hw.acpi.thermal.tz" .. warg .. ".temperature")

    if not temp then
        return {0}
    else
        return {string.match(temp, "[%d]+%.[%d]+")}
    end
end
-- }}}

return setmetatable(thermal_freebsd, { __call = function(_, ...) return worker(...) end })
