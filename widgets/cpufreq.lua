---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local setmetatable = setmetatable
local string = { match = string.match }
local helpers = require("vicious.helpers")
-- }}}


-- Cpufreq: provides freq, voltage and governor info for a requested CPU
module("vicious.widgets.cpufreq")


-- {{{ CPU frequency widget type
local function worker(format, warg)
    if not warg then return end

    local cpufreq = helpers.pathtotable("/sys/devices/system/cpu/"..warg.."/cpufreq")
    local governor_state = {
       ["ondemand\n"]     = "↯",
       ["powersave\n"]    = "⌁",
       ["userspace\n"]    = "¤",
       ["performance\n"]  = "⚡",
       ["conservative\n"] = "↯"
    }
    -- Default voltage values
    local voltage = { v  = "N/A", mv = "N/A" }


    -- Get the current frequency
    local freq = tonumber(cpufreq.scaling_cur_freq)
    -- Calculate MHz and GHz
    local freqmhz = freq / 1000
    local freqghz = freqmhz / 1000

    -- Get the current voltage
    if cpufreq.scaling_voltages then
        voltage.mv = tonumber(string.match(cpufreq.scaling_voltages, freq.."[%s]([%d]+)"))
        -- Calculate voltage from mV
        voltage.v = voltage.mv / 1000
    end

    -- Get the current governor
    local governor = cpufreq.scaling_governor
    -- Represent the governor as a symbol
    governor = governor_state[governor] or governor

    return {freqmhz, freqghz, voltage.mv, voltage.v, governor}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
