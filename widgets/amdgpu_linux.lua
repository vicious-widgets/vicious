-- contrib/amdgpu_linux.lua
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
local helpers = require("vicious.helpers")

-- {{{ AMDGPU widget type
return helpers.setcall(function (format, warg)
    if not warg then return end

    local amdgpu = "/sys/class/drm/"..warg.."/device"
    local _data = {}
    local _mem = nil

    local f = io.open(amdgpu .. "/gpu_busy_percent", "r")
    if f then
        for line in f:lines() do
            _data["{gpu_usage}"] = line
        end
        f:close()
    else
        _data["{gpu_usage}"] = "N/A"
    end

    if _mem == nil then
        f = io.open(amdgpu .. "/mem_info_vram_total", "r")
        if f then
            for line in f:lines() do
                _mem = line
            end
            f:close()
        end
    end

    f = io.open(amdgpu .. "/mem_info_vram_used", "r")
    if f then
        for line in f:lines() do
            _data["{mem_usage}"] = line/_mem*100
        end
        f:close()
    else
        _data["{mem_usage}"] = "N/A"
    end

    return _data

end)
--}}}
