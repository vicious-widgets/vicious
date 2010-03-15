---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { lines = io.lines }
local setmetatable = setmetatable
local string = { gmatch = string.gmatch }
-- }}}


-- Cpuinf: provides speed and cache information for all available CPUs/cores
module("vicious.widgets.cpuinf")


-- {{{ CPU Information widget type
local function worker(format)
    local id = nil

    local cpu_info = {} -- Get CPU info
    for line in io.lines("/proc/cpuinfo") do
        for k, v in string.gmatch(line, "([%a%s]+)[%s]+:[%s]([%d]+).-$") do
            if k == "processor" then
                id = v
            elseif k == "cpu MHz\t" or k == "cpu MHz" then
                local speed = tonumber(v)
                cpu_info["{cpu"..id.." mhz}"] = speed
                cpu_info["{cpu"..id.." ghz}"] = speed / 1000
            elseif k == "cache size" then
                local cache = tonumber(v)
                cpu_info["{cpu"..id.." kb}"] = cache
                cpu_info["{cpu"..id.." mb}"] = cache / 1024
            end
        end
    end

    return cpu_info
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
