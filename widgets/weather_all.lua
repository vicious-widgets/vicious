---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
local math = { ceil = math.ceil }
local string = { match = string.match }

-- Awesome library for spawning programs
local spawn = require"awful.spawn"

local helpers = require("vicious.helpers")
-- }}}


-- Weather: provides weather information for a requested station
-- vicious.widgets.weather
local weather_all = {}


-- {{{ Weather widget type
local function parse(ws)
    -- Initialize function tables
    local _weather = {
        ["{city}"]    = "N/A",
        ["{wind}"]    = "N/A",
        ["{windmph}"] = "N/A",
        ["{windkmh}"] = "N/A",
        ["{sky}"]     = "N/A",
        ["{weather}"] = "N/A",
        ["{tempf}"]   = "N/A",
        ["{tempc}"]   = "N/A",
        ["{dewf}"]    = "N/A",
        ["{dewc}"]    = "N/A",
        ["{humid}"]   = "N/A",
        ["{press}"]   = "N/A"
    }

    -- Check if there was a timeout or a problem with the station
    if ws == '' then return _weather end

    _weather["{city}"]    = -- City and/or area
       string.match(ws, "^(.+)%,.*%([%u]+%)") or _weather["{city}"]
    _weather["{wind}"]    = -- Wind direction and degrees if available
       string.match(ws, "Wind:[%s][%a]+[%s][%a]+[%s](.+)[%s]at.+$") or _weather["{wind}"]
    _weather["{windmph}"] = -- Wind speed in MPH if available
       string.match(ws, "Wind:[%s].+[%s]at[%s]([%d]+)[%s]MPH") or _weather["{windmph}"]
    _weather["{sky}"]     = -- Sky conditions if available
       string.match(ws, "Sky[%s]conditions:[%s](.-)[%c]") or _weather["{sky}"]
    _weather["{weather}"] = -- Weather conditions if available
       string.match(ws, "Weather:[%s](.-)[%c]") or _weather["{weather}"]
    _weather["{tempf}"]   = -- Temperature in fahrenheit
       string.match(ws, "Temperature:[%s]([%-]?[%d%.]+).*[%c]") or _weather["{tempf}"]
    _weather["{dewf}"]    = -- Dew Point in fahrenheit
       string.match(ws, "Dew[%s]Point:[%s]([%-]?[%d%.]+).*[%c]") or _weather["{dewf}"]
    _weather["{humid}"]   = -- Relative humidity in percent
       string.match(ws, "Relative[%s]Humidity:[%s]([%d]+)%%") or _weather["{humid}"]
    _weather["{press}"]   = -- Pressure in hPa
       string.match(ws, "Pressure[%s].+%((.+)[%s]hPa%)") or _weather["{press}"]

    -- Wind speed in km/h if MPH was available
    if _weather["{windmph}"] ~= "N/A" then
       _weather["{windmph}"] = tonumber(_weather["{windmph}"])
       _weather["{windkmh}"] = math.ceil(_weather["{windmph}"] * 1.6)
    end -- Temperature in °C if °F was available
    if _weather["{tempf}"] ~= "N/A" then
       _weather["{tempf}"] = tonumber(_weather["{tempf}"])
       _weather["{tempc}"] = math.ceil((_weather["{tempf}"] - 32) * 5/9)
    end -- Dew Point in °C if °F was available
    if _weather["{dewf}"] ~= "N/A" then
       _weather["{dewf}"] = tonumber(_weather["{dewf}"])
       _weather["{dewc}"] = math.ceil((_weather["{dewf}"] - 32) * 5/9)
    end -- Capitalize some stats so they don't look so out of place
    if _weather["{sky}"] ~= "N/A" then
       _weather["{sky}"] = helpers.capitalize(_weather["{sky}"])
    end
    if _weather["{weather}"] ~= "N/A" then
       _weather["{weather}"] = helpers.capitalize(_weather["{weather}"])
    end

    return _weather
end

function weather_all.async(format, warg, callback)
    if not warg then return end

    -- Get weather forceast by the station ICAO code, from:
    -- * US National Oceanic and Atmospheric Administration
    local url = ("https://tgftp.nws.noaa.gov/data/observations/metar/decoded/%s.TXT"):format(warg)
    local cmd = "curl -fs " .. helpers.shellquote(url)
    spawn.easy_async(cmd, function (stdout) callback(parse(stdout)) end)
end

local function worker(format, warg)
    local ret
    weather_all.async(format, warg, function (weather) ret = weather end)
    while ret == nil do end
    return ret
end
-- }}}

return setmetatable(weather_all, { __call = function(_, ...) return worker(...) end })
