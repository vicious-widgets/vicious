-- widget type providing name-indexed temperatures from /sys/class/hwmon
-- Copyright (C) 2019, 2020  Alexander Koch <lynix47@gmail.com>
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

-- environment
local type = type
local tonumber = tonumber
local io = { open = io.open }

local helpers = require"vicious.helpers"
local spawn = require"vicious.spawn"

local pathcache = {}

local function read_sensor(path, callback)
    local f = io.open(path, "r")
    callback{ tonumber(f:read"*line") / 1000 }
    f:close()
end

-- hwmontemp: provides name-indexed temps from /sys/class/hwmon
-- vicious.widgets.hwmontemp
return helpers.setasyncall{
    async = function (format, warg, callback)
        if type(warg) ~= "table" or type(warg[1]) ~= "string" then
            return callback{}
        end

        local input = warg[2]
        if type(input) == "number" then
            input = ("temp%d_input"):format(input)
        else
            input = "temp1_input"
        end

        local sensor = warg[1]
        if pathcache[sensor] then
            read_sensor(pathcache[sensor] .. input, callback)
        else
            spawn.easy_async_with_shell(
                "grep " .. sensor .. " -wl /sys/class/hwmon/*/name",
                function (stdout, stderr, exitreason, exitcode)
                    if exitreason == "exit" and exitcode == 0 then
                        pathcache[sensor] = stdout:gsub("name%s+", "")
                        read_sensor(pathcache[sensor] .. input, callback)
                    else
                        callback{}
                    end
                end)
        end
    end }
-- vim: ts=4:sw=4:expandtab
