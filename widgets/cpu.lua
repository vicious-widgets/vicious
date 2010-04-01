---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
--  * (c) 2009, Lucas de Vries <lucas@glacicle.com>
---------------------------------------------------

-- {{{ Grab environment
local ipairs = ipairs
local io = { lines = io.lines }
local setmetatable = setmetatable
local math = { floor = math.floor }
local table = { insert = table.insert }
local string = {
    find = string.find,
    gmatch = string.gmatch
}
-- }}}


-- Cpu: provides CPU usage for all available CPUs/cores
module("vicious.widgets.cpu")


-- Initialize function tables
local cpu_usage  = {}
local cpu_total  = {}
local cpu_active = {}

-- {{{ CPU widget type
local function worker(format)
    local cpu_lines = {}

    -- Get CPU stats
    for line in io.lines("/proc/stat") do
        if string.find(line, "^cpu") then
            cpu_lines[#cpu_lines+1] = {}

            for i in string.gmatch(line, "[%s]+([%d]+)") do
                  table.insert(cpu_lines[#cpu_lines], i)
            end
        end
    end

    -- Ensure tables are initialized correctly
    while #cpu_total < #cpu_lines do
        table.insert(cpu_total,  0)
        table.insert(cpu_active, 0)
        table.insert(cpu_usage,  0)
    end

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
