---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local setmetatable = setmetatable
local string = { format = string.format }
local helpers = require("vicious.helpers")
local math = {
    min = math.min,
    floor = math.floor
}
-- }}}


-- Bat: provides state, charge, and remaining time for a requested battery
module("vicious.widgets.bat")


-- {{{ Battery widget type
local function worker(format, warg)
    if not warg then return end

    local battery = helpers.pathtotable("/sys/class/power_supply/"..warg)
    local battery_state = {
        ["Full\n"]        = "↯",
        ["Unknown\n"]     = "⌁",
        ["Charged\n"]     = "↯",
        ["Charging\n"]    = "+",
        ["Discharging\n"] = "-"
    }

    -- Check if the battery is present
    if battery.present ~= "1\n" then
        return {battery_state["Unknown\n"], 0, "N/A"}
    end


    -- Get state information
    local state = battery_state[battery.status] or battery_state["Unknown\n"]

    -- Get capacity information
    if battery.charge_now then
        remaining, capacity = battery.charge_now, battery.charge_full
    elseif battery.energy_now then
        remaining, capacity = battery.energy_now, battery.energy_full
    else
        return {battery_state["Unknown\n"], 0, "N/A"}
    end

    -- Calculate percentage (but work around broken BAT/ACPI implementations)
    local percent = math.min(math.floor(remaining / capacity * 100), 100)


    -- Get charge information
    if battery.current_now then
        rate = battery.current_now
    else -- Todo: other rate sources, as with capacity?
        return {state, percent, "N/A"}
    end

    -- Calculate remaining (charging or discharging) time
    if state == "+" then
        timeleft = (tonumber(capacity) - tonumber(remaining)) / tonumber(rate)
    elseif state == "-" then
        timeleft = tonumber(remaining) / tonumber(rate)
    else
        return {state, percent, "N/A"}
    end
    local hoursleft = math.floor(timeleft)
    local minutesleft = math.floor((timeleft - hoursleft) * 60 )
    local time = string.format("%02d:%02d", hoursleft, minutesleft)

    return {state, percent, time}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
