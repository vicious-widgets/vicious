-- battery widget type for OpenBSD
-- Copyright (C) 2019  Enric Morales <me@enric.me>
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
local pairs = pairs
local tonumber = tonumber
local table = {
    insert = table.insert
}

local math = {
    floor = math.floor,
    modf = math.modf
}

local helpers = require("vicious.helpers")
-- }}}

local bat_openbsd = {}
function bat_openbsd.async(format, warg, callback)
    local battery_id = warg or "bat0"

    local fields = {
        charging_rate = ("hw.sensors.acpi%s.power0"):format(battery_id),
        last_full_capacity = ("hw.sensors.acpi%s.watthour0"):format(battery_id),
        remaining_capacity = ("hw.sensors.acpi%s.watthour3"):format(battery_id),
        design_capacity = ("hw.sensors.acpi%s.watthour4"):format(battery_id),
        state = ("hw.sensors.acpi%s.raw0"):format(battery_id)
    }

    local sysctl_args = {}
    for _, v in pairs(fields) do table.insert(sysctl_args, v) end

    local battery = {}
    helpers.sysctl_async(sysctl_args, function (ret)
            for k, v in pairs(fields) do
                -- discard the description that comes after the values
                battery[k] = tonumber(ret[v]:match("(.-) "))
            end

            local states = {
                [0] = "↯",      -- not charging
                [1] = "-",      -- discharging
                [2] = "!",      -- critical
                [3] = "+",      -- charging
                [4] = "N/A",    -- unknown status
                [255] = "N/A"   -- unimplemented by the driver
            }
            local state = states[battery.state]

            local charge = tonumber(battery.remaining_capacity
                                    / battery.last_full_capacity * 100)

            local remaining_time
            if battery.charging_rate < 1 then
                remaining_time = "∞"
            else
                local raw_time = battery.remaining_capacity / battery.rate
                local hours, hour_fraction = math.modf(raw_time)
                local minutes = math.floor(60 * hour_fraction)
                remaining_time = ("%d:%0.2d"):format(hours, minutes)
            end

            local wear = math.floor(battery.last_full_capacity,
                                    battery.design_capacity)

            -- Pass the following arguments to callback function:
            --  * battery state symbol (↯, -, !, + or N/A)
            --  * remaining capacity (in percent)
            --  * remaining time, as reported by the battery
            --  * wear level (in percent)
            --  * present_rate (in Watts/hour)
            return callback({ state, charge, remaining_time,
                              wear, battery.charging_rate })
    end)
end

return helpers.setasyncall(bat_openbsd)
