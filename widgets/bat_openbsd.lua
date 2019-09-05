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
local tonumber = tonumber
local math = { floor = math.floor, modf = math.modf }

local helpers = require"vicious.helpers"
local spawn = require"vicious.spawn"
-- }}}

local STATES = { [0] = "↯",         -- not charging
                 [1] = "-",         -- discharging
                 [2] = "!",         -- critical
                 [3] = "+",         -- charging
                 [4] = "N/A",       -- unknown status
                 [255] = "N/A" }    -- unimplemented by the driver

return helpers.setasyncall{
    async = function (format, warg, callback)
        local filter = "hw.sensors.acpi" .. (warg or "bat0")
        local pattern = filter .. ".(%S+)=(%S+)"
        local bat_info = {}

        spawn.with_line_callback_with_shell(
            ("sysctl -a | grep '^%s'"):format(filter),
            { stdout = function (line)
                  for key, value in line:gmatch(pattern) do
                      bat_info[key] = value
                  end
              end,
              output_done = function ()
                  -- current state
                  local state = STATES[tonumber(bat_info.raw0)]

                  -- battery capacity in percent
                  local percent = tonumber(
                      bat_info.watthour3 / bat_info.watthour0 * 100)

                  local time
                  if tonumber(bat_info.power0) < 1 then
                      time = "∞"
                  else
                      local raw_time = bat_info.watthour3 / bat_info.power0
                      local hours, hour_fraction = math.modf(raw_time)
                      local minutes = math.floor(60 * hour_fraction)
                      time = ("%d:%0.2d"):format(hours, minutes)
                  end

                  -- calculate wear level from (last full / design) capacity
                  local wear = "N/A"
                  if bat_info.watthour0 and bat_info.watthour4 then
                      local l_full = tonumber(bat_info.watthour0)
                      local design = tonumber(bat_info.watthour4)
                      wear = math.floor(l_full / design * 100)
                  end

                  -- dis-/charging rate as presented by battery
                  local rate = bat_info.power0

                  -- Pass the following arguments to callback function:
                  --  * battery state symbol (↯, -, !, + or N/A)
                  --  * remaining_capacity (in percent)
                  --  * remaining_time, by battery
                  --  * wear level (in percent)
                  --  * present_rate (in Watts)
                  callback{state, percent, time, wear, rate}
              end })
    end }
