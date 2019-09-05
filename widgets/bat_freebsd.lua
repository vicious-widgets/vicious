-- battery widget type for FreeBSD
-- Copyright (C) 2017-2019  mutlusun <mutlusun@github.com>
-- Copyright (C) 2019  Nguyễn Gia Phong <vn.mcsinyx@gmail.com>
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
local math = { floor = math.floor }
local string = {
    gmatch = string.gmatch,
    format = string.format
}

local helpers = require("vicious.helpers")
local spawn = require("vicious.spawn")
-- }}}

-- Battery: provides battery level of requested battery
-- vicious.widgets.battery_freebsd
local bat_freebsd = {}

-- {{{ Battery widget type
local function parse(stdout, stderr, exitreason, exitcode)
    local bat_info = {}
    for line in string.gmatch(stdout, "[^\n]+") do
        for key,value in string.gmatch(line, "(.+):%s+(.+)") do
            bat_info[key] = value
        end
    end

    -- current state
    -- see: https://github.com/freebsd/freebsd/blob/master/usr.sbin/acpi/acpiconf/acpiconf.c
    local battery_state = {
        ["high"]                    = "↯",
        ["charging"]                = "+",
        ["critical charging"]       = "+",
        ["discharging"]             = "-",
        ["critical discharging"]    = "!",
        ["critical"]                = "!",
    }
    local state = battery_state[bat_info["State"]] or "N/A"

    -- battery capacity in percent
    local percent = tonumber(bat_info["Remaining capacity"]:match"[%d]+")

    -- use remaining (charging or discharging) time calculated by acpiconf
    local time = bat_info["Remaining time"]
    if time == "unknown" then
        time = "∞"
    end

    -- calculate wear level from (last full / design) capacity
    local wear = "N/A"
    if bat_info["Last full capacity"] and bat_info["Design capacity"] then
        local l_full = tonumber(bat_info["Last full capacity"]:match"[%d]+")
        local design = tonumber(bat_info["Design capacity"]:match"[%d]+")
        wear = math.floor(l_full / design * 100)
    end

    -- dis-/charging rate as presented by battery
    local rate = bat_info["Present rate"]:match"([%d]+)%smW"
    rate = string.format("%2.1f", tonumber(rate / 1000))

    -- returns
    --  * state (high "↯", discharging "-", charging "+", N/A "⌁" }
    --  * remaining_capacity (percent)
    --  * remaining_time, by battery
    --  * wear level (percent)
    --  * present_rate (mW)
    return {state, percent, time, wear, rate}
end

function bat_freebsd.async(format, warg, callback)
    local battery = warg or "batt"
    spawn.easy_async("acpiconf -i " .. helpers.shellquote(battery),
                     function (...) callback(parse(...)) end)
end
-- }}}

return helpers.setasyncall(bat_freebsd)
