-- fan speed widget type for FreeBSD
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
local tonumber = tonumber
local type = type

local helpers = require("vicious.helpers")
-- }}}

-- fanspeed: provides speed level of fans
-- vicious.widgets.fanspeed
--
-- expects one or multiple full sysctl strings to entry
--   e.g.: "dev.acpi_ibm.0.fan_speed"
local fanspeed_freebsd = {}

-- {{{ fanspeed widget type
function fanspeed_freebsd.async(format, warg, callback)
    if not warg then return callback({}) end
    if type(warg) ~= "table" then warg = { warg } end

    helpers.sysctl_async(warg, function(ret)
        local fanspeed = {}

        for i=1,#warg do
            if ret[warg[i]] ~= nil then
                fanspeed[i] = tonumber(ret[warg[i]])
            else
                fanspeed[i] = "N/A"
            end
        end

        callback(fanspeed)
    end)
end
-- }}}

return helpers.setasyncall(fanspeed_freebsd)
