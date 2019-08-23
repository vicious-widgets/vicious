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
