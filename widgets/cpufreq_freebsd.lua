-- CPU frequency widget type for FreeBSD
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
local helpers = require("vicious.helpers")
-- }}}

-- Cpufreq: provides freq, voltage and governor info for a requested CPU
-- vicious.widgets.cpufreq
local cpufreq_freebsd = {}

-- {{{ CPU frequency widget type
function cpufreq_freebsd.async(format, warg, callback)
    if not warg then return callback({}) end

    -- Default frequency and voltage values
    local freqv = {
        ["mhz"] = "N/A", ["ghz"] = "N/A",
        ["v"]   = "N/A", ["mv"]  = "N/A",
        ["governor"] = "N/A",
    }

    helpers.sysctl_async(
        { "dev.cpu." .. warg .. ".freq" },
        function (ret)
            freqv.mhz = tonumber(ret["dev.cpu." .. warg .. ".freq"])
            freqv.ghz = freqv.mhz / 1000

            return callback({
                freqv.mhz,
                freqv.ghz,
                freqv.mv,
                freqv.v,
                freqv.governor
            })
        end)
end
-- }}}

return helpers.setasyncall(cpufreq_freebsd)
