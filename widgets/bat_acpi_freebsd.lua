-----------------------------------------------------
-- Battery: use acpiconf to get more information
--          from the battery
-----------------------------------------------------
local setmetatable = setmetatable

local bat_acpi = {}

local function worker(format)
    local bat_info = {}
    local pcall = "acpiconf -i batt"
    local f = io.popen(pcall)
    for line in f:lines("*line") do
        for key,value in string.gmatch(line, "(.+):%s+(.+)") do
            bat_info[key] = value
        end
    end
    f.close()

    -- current state
    local state
    if bat_info["State"] == "high" then
        state =  "↯"
    elseif bat_info["State"] == "charging" then
        state = "+"
    elseif bat_info["State"] == "discharging" then
        state = "-"
    else
        state = "⌁"
    end

    -- battery capacity in percent
    local percent = tonumber(string.gsub(bat_info["Remaining capacity"], "[^%d]", ""), 10)

    -- Calculate remaining (charging or discharging) time
    local time = bat_info["Remaining time"]
    if time == "unknown" then
        time = "∞"
    end

    -- dis-/charging rate as presented by battery
    local rate = string.gsub( string.gsub(bat_info["Present rate"], ".*mA[^%d]+", ""), "[%s]+mW.*", "")
    rate = string.format( "% 2.1f", tonumber(rate / 1000))

    -- returns
    --  * state (high "↯", discharging "-", charging "+", N/A "⌁" }
    --  * remaining_capacity (percent)
    --  * remaining_time, by battery
    --  * present_rate (mW)
    return {state, percent, time, rate}
end

return setmetatable(bat_acpi, { __call = function(_, ...) return worker(...) end })
