-- {{{ Grab environment
local setmetatable = setmetatable
local tonumber = tonumber
local string = { format = string.format, gmatch = string.gmatch }
local io = { popen = io.popen }
local math = { floor = math.floor }
-- }}}

local bat_openbsd = {}

local function worker(format, warg)
    local battery = warg or "bat0"
    local filter = string.format("hw.sensors.acpi%s", battery)
    local cmd = string.format("sysctl -a | grep '^%s'", filter)
    local proc = io.popen(cmd)

    local bat_info = {}
    for line in proc:lines("*l") do
        for key, value in string.gmatch(line, "(%S+)=(%S+)") do
	    key = key:gsub(filter .. ".", "")
	    bat_info[key] = value
        end
    end

    -- current state
    local states = {[0] = "↯", -- not charging
                    [1] = "-", -- discharging
                    [2] = "!", -- critical
                    [3] = "+", -- charging
                    [4] = "N/A", -- unknown status
                    [255] = "N/A"} -- unimplemented by the driver
    local state = states[tonumber(bat_info.raw0)]

    -- battery capacity in percent
    local percent = tonumber(bat_info.watthour3 / bat_info.watthour0 * 100)

    local time
    if tonumber(bat_info.power0) < 1 then
        time = "∞"
    else
	local raw_time = bat_info.watthour3 / bat_info.power0
	local hours = math.floor(raw_time)
	local minutes = raw_time % 1
	time = string.format("%d:%0.2d", hours, minutes)
    end

    -- calculate wear level from (last full / design) capacity
    local wear = "N/A"
    if bat_info.watthour0 and bat_info.watthour4 then
        local l_full = tonumber(bat_info.watthour0)
        local design = tonumber(bat_info.watthour4)
        wear = math.floor(l_full / design * 100)
    end

    -- dis-/charging rate as presented by battery
    local rate = bat_info.power0

    -- returns
    --  * state (high "↯", discharging "-", charging "+", N/A "⌁" }
    --  * remaining_capacity (percent)
    --  * remaining_time, by battery
    --  * wear level (percent)
    --  * present_rate (W)
    return {state, percent, time, wear, rate}
end

return setmetatable(bat_openbsd, { __call = function(_, ...) return worker(...) end })
