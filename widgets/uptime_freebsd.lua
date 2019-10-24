-- uptime widget type for FreeBSD
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
local math = { floor = math.floor }
local os = { time = os.time }

local helpers = require("vicious.helpers")
-- }}}

-- Uptime: provides system uptime and load information
-- vicious.widgets.uptime
local uptime_freebsd = {}

-- {{{ Uptime widget type
function uptime_freebsd.async(format, warg, callback)
    helpers.sysctl_async(
        { "vm.loadavg", "kern.boottime" },
        function(ret)
            local l1, l5, l15 = ret["vm.loadavg"]:match(
                "{ ([%d]+%.[%d]+) ([%d]+%.[%d]+) ([%d]+%.[%d]+) }")
            local up_t = os.time() - tonumber(
                ret["kern.boottime"]:match"sec = ([%d]+)")

            -- Get system uptime
            local up_d = math.floor(up_t   / (3600 * 24))
            local up_h = math.floor((up_t  % (3600 * 24)) / 3600)
            local up_m = math.floor(((up_t % (3600 * 24)) % 3600) / 60)

            return callback({ up_d, up_h, up_m, l1, l5, l15 })
        end)
end
-- }}}

return helpers.setasyncall(uptime_freebsd)
