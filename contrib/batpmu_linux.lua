-- contrib/batpmu_linux.lua
-- Copyright (C) 2010  Adrian C. <anrxc@sysphere.org>
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
local io = { open = io.open }
local setmetatable = setmetatable
local math = {
    min = math.min,
    floor = math.floor
}
local string = {
    find = string.find,
    match = string.match,
    format = string.format
}
-- }}}


-- Batpmu: provides state, charge and remaining time for a requested battery using PMU
-- vicious.contrib.batpmu
local batpmu_linux = {}


-- {{{ Battery widget type
local function worker(format, batid)
    local battery_state = {
        ["full"] = "↯",
        ["unknown"] = "⌁",
        ["00000013"] = "+",
        ["00000011"] = "-"
    }

    -- Get /proc/pmu/battery* state
    local f = io.open("/proc/pmu/" .. batid)
    -- Handler for incompetent users
    if not f then return {battery_state["unknown"], 0, "N/A"} end
    local statefile = f:read("*all")
    f:close()

    -- Get /proc/pmu/info data
    local f = io.open("/proc/pmu/info")
    local infofile = f:read("*all")
    f:close()

    -- Check if the battery is present
    if infofile == nil or string.find(infofile, "Battery count[%s]+:[%s]0") then
        return {battery_state["unknown"], 0, "N/A"}
    end


    -- Get capacity and charge information
    local capacity = string.match(statefile, "max_charge[%s]+:[%s]([%d]+).*")
    local remaining = string.match(statefile, "charge[%s]+:[%s]([%d]+).*")

    -- Calculate percentage
    local percent = math.min(math.floor(remaining / capacity * 100), 100)


    -- Get timer information
    local timer = string.match(statefile, "time rem%.[%s]+:[%s]([%d]+).*")
    if timer == "0" then return {battery_state["full"], percent, "N/A"} end

    -- Get state information
    local state = string.match(statefile, "flags[%s]+:[%s]([%d]+).*")
    local state = battery_state[state] or battery_state["unknown"]

    -- Calculate remaining (charging or discharging) time
    local hoursleft = math.floor(tonumber(timer) / 3600)
    local minutesleft = math.floor((tonumber(timer) / 60) % 60)
    local time = string.format("%02d:%02d", hoursleft, minutesleft)

    return {state, percent, time}
end
-- }}}

return setmetatable(batpmu_linux, { __call = function(_, ...) return worker(...) end })
