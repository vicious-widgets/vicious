-- temperature widget type for FreeBSD
-- Copyright (C) 2017,2019  mutlusun <mutlusun@github.com>
-- Copyright (C) 2019  Nguyễn Gia Phong <vn.mcsinyx@gmail.com>
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
local string = { match = string.match }
local type = type

local helpers = require("vicious.helpers")
-- }}}

-- Thermal: provides temperature levels of ACPI and coretemp thermal zones
-- vicious.widgets.thermal
local thermal_freebsd = {}

-- {{{ Thermal widget type
function thermal_freebsd.async(format, warg, callback)
    if not warg then return callback{} end
    if type(warg) ~= "table" then warg = { warg } end

    helpers.sysctl_async(warg, function(ret)
        local thermals = {}

        for i=1,#warg do
            if ret[warg[i]] ~= nil then
                thermals[i] = string.match(ret[warg[i]], "[%d]+")
            else
                thermals[i] = "N/A"
            end
        end

        callback(thermals)
    end)
end
-- }}}

return helpers.setasyncall(thermal_freebsd)
