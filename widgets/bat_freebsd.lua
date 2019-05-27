-- {{{ Grab environment
local tonumber = tonumber
local math = { floor = math.floor }
local helpers = require("vicious.helpers")
local spawn = require("vicious.spawn")
local string = {
    gmatch = string.gmatch,
    match = string.match,
    format = string.format
}
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

function bat_freebsd.async(format, warg, callback)
    local battery = warg or "batt"
    spawn.easy_async("acpiconf -i " .. helpers.shellquote(battery),
                     function (...) callback(parse(...)) end)
end
-- }}}

return helpers.setasyncall(bat_freebsd)
