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

-- Initialize function tables
local cpu_total = {}
local cpu_idle = {}

-- {{{ CPU widget type
local function worker(format)
    local cp_times = helpers.sysctl("kern.cp_times")
    local matches = {}
    local tmp_total = {}
    local tmp_idle = {}
    local tmp_usage = {}

    -- Read input data
    for v in string.gmatch(cp_times, "([%d]+)") do
        table.insert(matches, v)
    end

    -- Set first value of function tables
    if #cpu_total == 0 then  -- check for empty table
        for i = 1, #matches / 5 + 1 do
            cpu_total[i] = 0
            cpu_idle[i] = 0
        end
    end
    for i = 1, #matches / 5 + 1 do
        tmp_total[i] = 0
        tmp_idle[i] = 0
        tmp_usage[i] = 0
    end

    -- CPU usage 
    for i, v in ipairs(matches) do
        local index = math.floor((i-1) / 5) + 2 -- current cpu

        tmp_total[1] = tmp_total[1] + v
        tmp_total[index] = tmp_total[index] + v

        if (i-1) % 5 == 4 then
            tmp_idle[1] = tmp_idle[1] + v
            tmp_idle[index] = tmp_idle[index] + v
        end
    end

    for i = 1, #tmp_usage do
        tmp_usage[i] = tmp_total[i] - cpu_total[i]
        tmp_usage[i] = math.floor((tmp_usage[i] - (tmp_idle[i] - cpu_idle[i])) / tmp_usage[i] * 100)
    end

    cpu_total = tmp_total
    cpu_idle = tmp_idle

    return tmp_usage
end
-- }}}

return setmetatable(cpu_freebsd, { __call = function(_, ...) return worker(...) end })
