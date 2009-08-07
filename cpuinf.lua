----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
----------------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { open = io.open }
local setmetatable = setmetatable
-- }}}


-- Cpuinf: provides speed and cache information for all available CPUs/cores
module("vicious.cpuinf")


-- {{{ CPU Information widget type
local function worker(format)
    -- Initialise variables
    cpu_id = nil

    -- Get cpuinfo
    local f = io.open("/proc/cpuinfo")
    local cpu_info = {}

    -- Get data
    for line in f:lines() do
        if line:match("^processor.*") then
            cpu_id = line:match("([%d]+)")
        elseif line:match("^cpu MHz.*") then
            local cpu_speed = line:match("([%d]+)%.")
            -- Store values
            cpu_info["{"..cpu_id.." mhz}"] = cpu_speed
            cpu_info["{"..cpu_id.." ghz}"] = tonumber(cpu_speed) / 1000
        elseif line:match("^cache size.*") then
            local cpu_cache = line:match("([%d]+)[%s]KB")
            -- Store values
            cpu_info["{"..cpu_id.." kb}"] = cpu_cache
            cpu_info["{"..cpu_id.." mb}"] = tonumber(cpu_cache) / 1024
        end
    end
    f:close()

    return cpu_info
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
