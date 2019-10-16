-- CPU frequency widget type for GNU/Linux
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
local tonumber = tonumber
local helpers = require("vicious.helpers")
-- }}}

local GOVERNOR_STATE = {
    ["ondemand\n"]     = "↯",
    ["powersave\n"]    = "⌁",
    ["userspace\n"]    = "¤",
    ["performance\n"]  = "⚡",
    ["conservative\n"] = "⊚"
}

-- {{{ CPU frequency widget type
return helpers.setcall(function (format, warg)
    if not warg then return end

    local _cpufreq = helpers.pathtotable(
        ("/sys/devices/system/cpu/%s/cpufreq"):format(warg))
    -- Default frequency and voltage values
    local freqv = {
        ["mhz"] = "N/A", ["ghz"] = "N/A",
        ["v"]   = "N/A", ["mv"]  = "N/A",
    }

    -- Get the current frequency
    local freq = tonumber(_cpufreq.scaling_cur_freq)
    -- Calculate MHz and GHz
    if freq then
        freqv.mhz = freq / 1000
        freqv.ghz = freqv.mhz / 1000

        -- Get the current voltage
        if _cpufreq.scaling_voltages then
            freqv.mv = tonumber(
                _cpufreq.scaling_voltages:match(freq .. "[%s]([%d]+)"))
            -- Calculate voltage from mV
            freqv.v  = freqv.mv / 1000
        end
    end

    -- Get the current governor
    local governor = _cpufreq.scaling_governor
    -- Represent the governor as a symbol
    governor = GOVERNOR_STATE[governor] or governor or "N/A"

    return {freqv.mhz, freqv.ghz, freqv.mv, freqv.v, governor}
end)
-- }}}
