-- temperature widget type for GNU/Linux
-- Copyright (C) 2010  Adrian C. <anrxc@sysphere.org>
-- Copyright (C) 2017  mutlusun <mutlusun@github.com>
--
-- This file is part of Vicious.
--
-- Vicious is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as
-- published by the Free Software Foundation, either version 2 of the
-- License, or (at your option) any later version.
--
-- Vicious is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with Vicious.  If not, see <https://www.gnu.org/licenses/>.

-- {{{ Grab environment
local type = type
local tonumber = tonumber
local string = { match = string.match }
local math = { floor = math.floor }
local helpers = require("vicious.helpers")
-- }}}

-- {{{ Thermal widget type
return helpers.setcall(function (format, warg)
    if not warg then return end

    local zone = { -- Known temperature data sources
        ["sys"]  = {"/sys/class/thermal/",     file = "temp",       div = 1000},
        ["core"] = {"/sys/devices/platform/",  file = "temp2_input",div = 1000},
        ["hwmon"] = {"/sys/class/hwmon/",      file = "temp1_input",div = 1000},
        ["proc"] = {"/proc/acpi/thermal_zone/",file = "temperature"}
    } --  Default to /sys/class/thermal
    warg = type(warg) == "table" and warg or { warg, "sys" }

    -- Get temperature from thermal zone
    local _thermal = helpers.pathtotable(zone[warg[2]][1] .. warg[1])

    local data = warg[3] and _thermal[warg[3]] or _thermal[zone[warg[2]].file]
    if data then
        if zone[warg[2]].div then
            return {math.floor(data / zone[warg[2]].div)}
        else -- /proc/acpi "temperature: N C"
            return {tonumber(string.match(data, "[%d]+"))}
        end
    end

    return {0}
end)
-- }}}
