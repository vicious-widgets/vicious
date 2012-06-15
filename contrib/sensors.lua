---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Greg D. <jabbas@jabbas.pl>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
local table = { insert = table.insert }
local string = {
    gsub = string.gsub,
    match = string.match
}
-- }}}


-- Sensors: provides access to lm_sensors data
-- vicious.contrib.sensors
local sensors = {}


-- {{{ Split helper function
local function datasplit(str)
    -- Splitting strings into associative array
    -- with some magic to get the values right.
    str = string.gsub(str, "\n", ":")

    local tbl = {}
    string.gsub(str, "([^:]*)", function (v)
        if string.match(v, ".") then
            table.insert(tbl, v)
        end
    end)

    local assoc = {}
    for c = 1, #tbl, 2 do
        local k  = string.gsub(tbl[c], ".*_", "")
        local v  = tonumber(string.match(tbl[c+1], "[%d]+"))
        assoc[k] = v
    end

    return assoc
end
-- }}}

-- {{{ Sensors widget type
local function worker(format, warg)
    -- Get data from all sensors
    local f = io.popen("LANG=C sensors -uA")
    local lm_sensors = f:read("*all")
    f:close()

    local sensor_data = string.gsub(
        string.match(lm_sensors, warg..":\n(%s%s.-)\n[^ ]"), " ", "")

    -- One of: crit, max
    local divisor = "crit"
    local s_data  =  datasplit(sensor_data)

    if s_data[divisor] and s_data[divisor] > 0 then
        s_data.percent = s_data.input / s_data[divisor] * 100
    end

    return {s_data.input, tonumber(s_data.percent)}
end
-- }}}

return setmetatable(sensors, { __call = function(_, ...) return worker(...) end })
