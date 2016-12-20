---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
--  * (c) 2013, NormalRa  <normalrawr@gmail.com>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local setmetatable = setmetatable
local string = { format = string.format }
local helpers = require("vicious.helpers")
local math = { floor = math.floor }
-- }}}


-- Bat: provides state, charge, remaining time, and wear for a requested battery
-- vicious.widgets.bat
local bat_freebsd = {}


-- {{{ Battery widget type
local function worker(format)

    local battery_state = { "↯", "-", "+", "⌁" }
    local mybat = helpers.sysctl_table("hw.acpi.battery")

    -- Check if the battery is present
    if not mybat.life then
        return {battery_state[4], 0, "N/A", 0}
    end

    -- Get state information
    local state = battery_state[tonumber(mybat.state) + 1] or battery_state[4]
        
    -- Get capacity information
    local percent = tonumber(mybat.life)

    -- wear is not implemented yet
    -- could be possible to parse the output of acpiconf
    local wear = 0

    -- Calculate remaining (charging or discharging) time
    local time = tonumber(mybat.time)
    if time == -1 then
        time = "N/A"
    else
        time = string.format("%02d:%02d", math.floor(time/60), time%60)
    end

    return {state, percent, time, wear}
end
-- }}}

return setmetatable(bat_freebsd, { __call = function(_, ...) return worker(...) end })
