---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc.sysphere.org>
---------------------------------------------------

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
local function worker(format, cpuid)
    --local governor_state = {
    --    ["ondemand"] = "↯",
    --    ["powersave"] = "⌁",
    --    ["userspace"] = "°",
    --    ["performance"] = "⚡",
    --    ["conservative"] = "↯"
    --}

    -- Default voltage values
    local voltage = { v  = "N/A", mv = "N/A" }


    -- Get the current frequency
    local f = io.open("/sys/devices/system/cpu/"..cpuid.."/cpufreq/scaling_cur_freq")
    local freq = f:read("*line")
    f:close()

    -- Calculate MHz and GHz
    local freqmhz = freq / 1000
    local freqghz = freqmhz / 1000


    -- Get the current voltage
    local f = io.open("/sys/devices/system/cpu/"..cpuid.."/cpufreq/scaling_voltages")
    if f then for line in f:lines() do
        if string.find(line, "^"..freq) then
            voltage.mv = string.match(line, "[%d]+[%s]([%d]+)")
            break
        end
      end
      f:close()

      -- Calculate voltage from mV
      voltage.v = voltage.mv / 1000
    end


    -- Get the current governor
    local f = io.open("/sys/devices/system/cpu/"..cpuid.."/cpufreq/scaling_governor")
    local governor = f:read("*line")
    f:close()

    -- Represent the governor as a symbol
    --local governor = governor_state[governor] or governor

    return {freqmhz, freqghz, voltage.mv, voltage.v, governor}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
