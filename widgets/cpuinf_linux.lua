-- CPU information widget type for GNU/Linux
-- Copyright (C) 2010  Adrian C. <anrxc@sysphere.org>
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
local tonumber = tonumber
local io = { lines = io.lines }
local string = { gmatch = string.gmatch }
local helpers = require"vicious.helpers"
-- }}}

-- {{{ CPU Information widget type
return helpers.setcall(function ()
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
end)
-- }}}
