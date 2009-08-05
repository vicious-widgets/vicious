----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
----------------------------------------------------------

-- {{{ Grab environment
local ipairs = ipairs
local io = { open = io.open }
local setmetatable = setmetatable
local math = { floor = math.floor }
local table = { insert = table.insert }
-- }}}


-- Cpu: provides CPU usage for all available CPUs/cores
module("vicious.cpu")


-- Initialise function tables
local cpu_usage  = {}
local cpu_total  = {}
local cpu_active = {}

-- {{{ CPU widget type
function worker(format)
    -- Get /proc/stat
    local f = io.open("/proc/stat")
    local cpu_lines = {}

    -- Format data
    for line in f:lines() do
        if line:find("^cpu") then
            if #cpu_lines < 1 then cpuid = 1
            else cpuid = #cpu_lines + 1 end

            cpu_lines[cpuid] = {}
            for match in line:gmatch("[%s]+([%d]+)") do
                  table.insert(cpu_lines[cpuid], match)
            end
        end
    end
    f:close()

    -- Ensure tables are initialized correctly
    while #cpu_total < #cpu_lines do
        table.insert(cpu_total, 0)
    end
    while #cpu_active < #cpu_lines do
        table.insert(cpu_active, 0)
    end
    while #cpu_usage < #cpu_lines do
        table.insert(cpu_usage, 0)
    end

    -- Setup tables
    local total_new   = {}
    local active_new  = {}
    local diff_total  = {}
    local diff_active = {}

    for i, v in ipairs(cpu_lines) do
        -- Calculate totals
        total_new[i]  = 0
        for j = 1, #v do
            total_new[i] = total_new[i] + v[j]
        end
        active_new[i] = v[1] + v[2] + v[3]

        -- Calculate percentage
        diff_total[i]  = total_new[i]  - cpu_total[i]
        diff_active[i] = active_new[i] - cpu_active[i]
        cpu_usage[i]   = math.floor(diff_active[i] / diff_total[i] * 100)

        -- Store totals
        cpu_total[i]   = total_new[i]
        cpu_active[i]  = active_new[i]
    end

    return cpu_usage
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
