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
local helpers = require("vicious.helpers")
-- }}}


-- Weather: provides weather information for a requested station
module("vicious.widgets.weather")


-- Initialize function tables
local weather = {
    ["{city}"]    = "N/A",
    ["{wind}"]    = "N/A",
    ["{windmph}"] = "N/A",
    ["{windkmh}"] = "N/A",
    ["{sky}"]     = "N/A",
    ["{weather}"] = "N/A",
    ["{tempf}"]   = "N/A",
    ["{tempc}"]   = "N/A",
    ["{humid}"]   = "N/A",
    ["{press}"]   = "N/A"
}

-- {{{ Weather widget type
local function worker(format, warg)
    if not warg then return end

    -- Get weather forceast by the station ICAO code, from:
    -- * US National Oceanic and Atmospheric Administration
    local noaa = "http://weather.noaa.gov/pub/data/observations/metar/decoded/"
    local f = io.popen("curl --connect-timeout 1 -fsm 3 "..noaa..warg..".TXT")
    local ws = f:read("*all")
    f:close()

    -- Check if there was a timeout or a problem with the station
    if ws == nil then return weather end

    weather["{city}"]    = -- City and/or area
       string.match(ws, "^(.+)%,.*%([%u]+%)") or weather["{city}"]
    weather["{wind}"]    = -- Wind direction and degrees if available
       string.match(ws, "Wind:[%s][%a]+[%s][%a]+[%s](.+)[%s]at.+$") or weather["{wind}"]
    weather["{windmph}"] = -- Wind speed in MPH if available
       string.match(ws, "Wind:[%s].+[%s]at[%s]([%d]+)[%s]MPH") or weather["{windmph}"]
    weather["{sky}"]     = -- Sky conditions if available
       string.match(ws, "Sky[%s]conditions:[%s](.-)[%c]") or weather["{sky}"]
    weather["{weather}"] = -- Weather conditions if available
       string.match(ws, "Weather:[%s](.-)[%c]") or weather["{weather}"]
    weather["{tempf}"]   = -- Temperature in fahrenheit
       string.match(ws, "Temperature:[%s]([%-]?[%d%.]+).*[%c]") or weather["{tempf}"]
    weather["{humid}"]   = -- Relative humidity in percent
       string.match(ws, "Relative[%s]Humidity:[%s]([%d]+)%%") or weather["{humid}"]
    weather["{press}"]   = -- Pressure in hPa
       string.match(ws, "Pressure[%s].+%((.+)[%s]hPa%)") or weather["{press}"]

    -- Wind speed in km/h if MPH was available
    if weather["{windmph}"] ~= "N/A" then
       weather["{windmph}"] = tonumber(weather["{windmph}"])
       weather["{windkmh}"] = math.ceil(weather["{windmph}"] * 1.6)
    end -- Temperature in °C if °F was available
    if weather["{tempf}"] ~= "N/A" then
       weather["{tempf}"] = tonumber(weather["{tempf}"])
       weather["{tempc}"] = math.ceil((weather["{tempf}"] - 32) * 5/9)
    end -- Capitalize some stats so they don't look so out of place
    if weather["{sky}"] ~= "N/A" then
       weather["{sky}"] = helpers.capitalize(weather["{sky}"])
    end
    if weather["{weather}"] ~= "N/A" then
       weather["{weather}"] = helpers.capitalize(weather["{weather}"])
    end

    return weather
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
