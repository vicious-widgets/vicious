---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2011, Adrian C. <anrxc@sysphere.org>
--  * (c) 2009, Lucas de Vries <lucas@glacicle.com>
--  * (c) 2011, Jörg Thalheim <jthalheim@gmail.com>
---------------------------------------------------

-- {{{ Grab environment
local ipairs = ipairs
local io = { lines = io.lines }
local setmetatable = setmetatable
local math = { floor = math.floor }
local table = { insert = table.insert }
local string = {
    sub = string.sub,
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
        if string.sub(line, 1, 3) ~= "cpu" then break end

        cpu_lines[#cpu_lines+1] = {}

        for i in string.gmatch(line, "[%s]+([^%s]+)") do
            table.insert(cpu_lines[#cpu_lines], i)
        end
    end

    -- Ensure tables are initialized correctly
    for i = #cpu_total + 1, #cpu_lines do
        cpu_total[i]  = 0
        cpu_usage[i]  = 0
        cpu_active[i] = 0
    end


    for i, v in ipairs(cpu_lines) do
        -- Calculate totals
        local total_new = 0
        for j = 1, #v do
            total_new = total_new + v[j]
        end
        local active_new = total_new - (v[4] + v[5])

        -- Calculate percentage
        local diff_total  = total_new - cpu_total[i]
        local diff_active = active_new - cpu_active[i]

        if diff_total == 0 then diff_total = 1E-6 end
        cpu_usage[i]      = math.floor((diff_active / diff_total) * 100)

        -- Store totals
        cpu_total[i]   = total_new
        cpu_active[i]  = active_new
    end

    return cpu_usage
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
