-- {{{ Grab environment
local setmetatable = setmetatable
local tonumber = tonumber
local io = { popen = io.popen }
local math = { floor = math.floor }
local helpers = require("vicious.helpers")
local string = {
    gmatch = string.gmatch,
    match = string.match,
    format = string.format

}
-- }}}
local bat_freebsd = {}

local function worker(format, warg)
    local battery = warg or "batt"
    local bat_info = {}
    local f = io.popen("acpiconf -i " .. helpers.shellquote(battery))
    for line in f:lines("*line") do
        for key,value in string.gmatch(line, "(.+):%s+(.+)") do
            bat_info[key] = value
        end
    end
    f:close()

    -- current state
    local state
    if bat_info["State"] == "high" then
        state =  "↯"
    elseif bat_info["State"] == "charging" then
        state = "+"
    elseif bat_info["State"] == "critical charging" then
        state = "+"
    elseif bat_info["State"] == "discharging" then
        state = "-"
    else
        state = "⌁"
    end

    -- battery capacity in percent
    local percent = tonumber(string.match(bat_info["Remaining capacity"], "[%d]+"))

    -- use remaining (charging or discharging) time calculated by acpiconf
    local time = bat_info["Remaining time"]
    if time == "unknown" then
        time = "∞"
    end

    -- calculate wear level from (last full / design) capacity
    local wear = "N/A"
    if bat_info["Last full capacity"] and bat_info["Design capacity"] then
        local l_full = tonumber(string.match(bat_info["Last full capacity"], "[%d]+"))
        local design = tonumber(string.match(bat_info["Design capacity"], "[%d]+"))
        wear = math.floor(l_full / design * 100)
    end

    -- dis-/charging rate as presented by battery
    local rate = string.match(bat_info["Present rate"], "([%d]+)%smW")
    rate = string.format("%2.1f", tonumber(rate / 1000))

    -- returns
    --  * state (high "↯", discharging "-", charging "+", N/A "⌁" }
    --  * remaining_capacity (percent)
    --  * remaining_time, by battery
    --  * wear level (percent)
    --  * present_rate (mW)
    return {state, percent, time, wear, rate}
end

return setmetatable(bat_freebsd, { __call = function(_, ...) return worker(...) end })
