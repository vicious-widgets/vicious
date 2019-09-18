-- contrib/nvsmi_all.lua
-- Copyright (C) 2014  Adrian C. <anrxc@sysphere.org>
-- Copyright (C) 2017  Jörg Thalheim <joerg@higgsboson.tk>
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
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { match = string.match }
-- }}}


-- nvsmi: provides GPU information from nvidia SMI
-- vicious.contrib.nvsmi
local nvsmi_all = {}


-- {{{ GPU Information widget type
local function worker(format, warg)
    -- Fallback to querying first device
    if not warg then warg = "0" end

    -- Get data from smi
    -- * Todo: support more; MEMORY,UTILIZATION,ECC,POWER,CLOCK,COMPUTE,PIDS,PERFORMANCE
    local f = io.popen("nvidia-smi -q -d TEMPERATURE -i " .. warg)
    local smi = f:read("*all")
    f:close()

    -- Not installed
    if smi == nil then return {0} end

    -- Get temperature information
    local _thermal = string.match(smi, "Gpu[%s]+:[%s]([%d]+)[%s]C")
    -- Handle devices without data
    if _thermal == nil then return {0} end

    return {tonumber(_thermal)}
end
-- }}}

return setmetatable(nvsmi_all, { __call = function(_, ...) return worker(...) end })
