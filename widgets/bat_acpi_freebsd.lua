-----------------------------------------------------
-- Battery: use acpiconf to get more information
--          from the battery
-----------------------------------------------------
local setmetatable = setmetatable
local bat_acpi = {}

local function worker(format)
    local battery = "batt"
    if warg then
        battery = warg
    end
    local bat_info = {}
    local pcall = "acpiconf -i " .. battery
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

    -- use remaining (charging or discharging) time calculated by acpiconf
    local time = bat_info["Remaining time"]
    if time == "unknown" then
        time = "∞"
    end

    -- calculate wear level from (last full / design) capacity
    local wear = "N/A"
    if bat_info["Last full capacity"] and bat_info["Design capacity"] then
        local l_full =  tonumber(string.gsub(bat_info["Last full capacity"], "[^%d]", ""), 10)
        local design = tonumber(string.gsub(bat_info["Design capacity"], "[^%d]", ""), 10)
        wear = math.floor( 100 - (l_full / design * 100))
    end

    -- dis-/charging rate as presented by battery
    local rate = string.gsub( string.gsub(bat_info["Present rate"], ".*mA[^%d]+", ""), "[%s]+mW.*", "")
    rate = string.format( "% 2.1f", tonumber(rate / 1000))

    -- returns
    --  * state (high "↯", discharging "-", charging "+", N/A "⌁" }
    --  * remaining_capacity (percent)
    --  * remaining_time, by battery
    --  * wear level (percent)
    --  * present_rate (mW)
    return {state, percent, time, wear, rate}
end

return setmetatable(bat_acpi, { __call = function(_, ...) return worker(...) end })
