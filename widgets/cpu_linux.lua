-- CPU usage widget type for GNU/Linux
-- Copyright (C) 2009  Lucas de Vries <lucas@glacicle.com>
-- Copyright (C) 2011  Adrian C. <anrxc@sysphere.org>
-- Copyright (C) 2011  Jörg Thalheim <jthalheim@gmail.com>
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
local ipairs = ipairs
local io = { open = io.open }
local math = { floor = math.floor }
local table = { insert = table.insert }
local string = {
    sub = string.sub,
    gmatch = string.gmatch
}

local helpers = require"vicious.helpers"
-- }}}

-- Initialize function tables
local cpu_usage  = {}
local cpu_total  = {}
local cpu_active = {}

-- {{{ CPU widget type
return helpers.setcall(function ()
    local cpu_lines = {}

    -- Get CPU stats
    local f = io.open("/proc/stat")
    for line in f:lines() do
        if string.sub(line, 1, 3) ~= "cpu" then break end

        cpu_lines[#cpu_lines+1] = {}

        for i in string.gmatch(line, "[%s]+([^%s]+)") do
            table.insert(cpu_lines[#cpu_lines], i)
        end
    end
    f:close()

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
end)
-- }}}
