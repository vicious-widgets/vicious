-- AMD GPU widget type for Linux
-- Copyright (C) 2022  Rémy Clouard <shikamaru shikamaru fr>
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

local io = { open = io.open }
local string = { match = string.match }
local tonumber = tonumber
local type = type

local helpers = require("vicious.helpers")

local _mem = nil

-- {{{ AMDGPU widget type
return helpers.setcall(function (format, warg)
    if not warg then return end

    -- see https://www.kernel.org/doc/html/v5.9/gpu/amdgpu.html#busy-percent
    local amdgpu = "/sys/class/drm/"..warg.."/device"
    local _data = {}

    local f = io.open(amdgpu .. "/gpu_busy_percent", "r")
    if f then
        _data["{gpu_usage}"] = f:read("*line")
        f:close()
    else
        _data["{gpu_usage}"] = "N/A"
    end

    if _mem == nil then
        f = io.open(amdgpu .. "/mem_info_vram_total", "r")
        if f then
            _mem = tonumber(string.match(f:read("*line"), "([%d]+)"))
            f:close()
        end
    end

    f = io.open(amdgpu .. "/mem_info_vram_used", "r")
    if f then
        local _used = tonumber(string.match(f:read("*line"), "([%d]+)"))
        if type(_used) == 'number' and type(_mem) == 'number'
           and _mem > 0 then
            _data["{mem_usage}"] = _used/_mem*100
        else
            _data["{mem_usage}"] = "N/A"
        end
        f:close()
    else
        _data["{mem_usage}"] = "N/A"
    end

    return _data

end)
--}}}
