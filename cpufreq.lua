----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
----------------------------------------------------------

-- {{{ Grab environment
local io = { open = io.open }
local setmetatable = setmetatable
local string = {
    find = string.find,
    match = string.match
}
-- }}}


-- Cpufreq: provides freq, voltage and governor info for a requested CPU
module("vicious.cpufreq")


-- {{{ CPU frequency widget type
function worker(format, cpuid)
    -- Initialise tables
    --local governor_state = {
    --    ["ondemand"] = "↯",
    --    ["powersave"] = "⌁",
    --    ["userspace"] = "°",
    --    ["performance"] = "⚡",
    --    ["conservative"] = "↯"
    --}

    -- Get the current frequency
    local ffreq = io.open("/sys/devices/system/cpu/"..cpuid.."/cpufreq/scaling_cur_freq")
    local freq = ffreq:read("*line")
    ffreq:close()

    -- Calculate MHz and GHz
    local freqmhz = freq / 1000
    local freqghz = freqmhz / 1000


    -- Get the current voltage
    local fvolt = io.open("/sys/devices/system/cpu/"..cpuid.."/cpufreq/scaling_voltages")
    for line in fvolt:lines() do
        if line:find("^"..freq) then
            voltagemv = line:match("[%d]+[%s]([%d]+)")
            break
        end
    end
    fvolt:close()

    -- Calculate voltage from mV
    local voltagev = voltagemv / 1000


    -- Get the current governor
    local fgov = io.open("/sys/devices/system/cpu/"..cpuid.."/cpufreq/scaling_governor")
    local governor = fgov:read("*line")
    fgov:close()

    -- Represent the governor as a symbol
    --local governor = governor_state[governor] or governor

    return {freqmhz, freqghz, voltagemv, voltagev, governor}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
