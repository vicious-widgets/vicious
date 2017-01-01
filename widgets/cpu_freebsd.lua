---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2011, Adrian C. <anrxc@sysphere.org>
--  * (c) 2009, Lucas de Vries <lucas@glacicle.com>
--  * (c) 2011, Jörg Thalheim <jthalheim@gmail.com>
---------------------------------------------------

-- {{{ Grab environment
local helpers = require("vicious.helpers")
local tonumber = tonumber
local setmetatable = setmetatable
local math = { floor = math.floor }
local string = { gmatch = string.gmatch }
-- }}}


-- Cpu: provides CPU usage for all available CPUs/cores
-- vicious.widgets.cpu_freebsd
local cpu_freebsd = {}


-- {{{ CPU widget type
local function worker(format)
    local kern = helpers.sysctl_table("kern")
    local cpu_total = {}
    local cpu_idle = {}
    local cpu_pusage = {}
    local i = 0

    -- CPU usage over all cpus
    cpu_total[0] = 0
    for v in string.gmatch(kern.cp_time, "([%d]+)") do
        cpu_total[0] = cpu_total[0] + tonumber(v)
        cpu_idle[0] = tonumber(v)
    end

    i = 0
    for v in string.gmatch(kern.cp_times, "([%d]+)") do
        local index = math.floor(i/5) + 1

        if i % 5 == 0 then
            cpu_total[index] = 0
        elseif i % 5 == 4 then
            cpu_idle[index] = tonumber(v)
        end

        cpu_total[index] = cpu_total[index] + tonumber(v)

        i = i + 1
    end

    for i = 0, #cpu_total do
        print((cpu_total[i] - cpu_idle[i])/cpu_total[i])
        cpu_pusage[i + 1] = math.floor((cpu_total[i] - cpu_idle[i])/cpu_total[i] * 100)
    end

    return cpu_pusage
end
-- }}}

return setmetatable(cpu_freebsd, { __call = function(_, ...) return worker(...) end })
