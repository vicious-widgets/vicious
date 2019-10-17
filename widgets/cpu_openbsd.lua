-- CPU usage widget type for OpenBSD
-- Copyright (C) 2019  Enric Morales
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

local math = { ceil = math.ceil }
local string = { gmatch = string.gmatch }
local table = { insert = table.insert }
local tonumber = tonumber

local helpers = require("vicious.helpers")


-- cpu_openbsd: provides both a helper function that allows reading
-- the CPU usage on OpenBSD systems.
local cpu_openbsd = {}

-- Initialize the table that will contain the ticks spent in each subsystem
-- values: user, nice, system, spin, interrupts, idle
local ticks = { 0, 0, 0, 0, 0, 0 }

function cpu_openbsd.async(format, warg, callback)
    helpers.sysctl_async({ "kern.cp_time" },
        function (ret)
            local current_ticks = {}
            for match in string.gmatch(ret["kern.cp_time"], "(%d+)") do
                table.insert(current_ticks, tonumber(match))
            end

            local period_ticks = {}
            for i = 1, 6 do
                table.insert(period_ticks,
                             current_ticks[i] - ticks[i])
            end

            local cpu_total, cpu_busy = 0, 0
            for i = 1, 6 do cpu_total = cpu_total + period_ticks[i] end
            for i = 1, 5 do cpu_busy = cpu_busy + period_ticks[i] end

            local cpu_usage = math.ceil((cpu_busy / cpu_total) * 100)

            ticks = current_ticks
            return callback({ cpu_usage })
        end)
end

return helpers.setasyncall(cpu_openbsd)
