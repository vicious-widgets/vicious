---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local setmetatable = setmetatable
local math = { floor = math.floor }
local string = { match = string.match }
-- }}}


-- Weather: provides weather information for a requested station
module("vicious.weather")


-- {{{ Weather widget type
local function worker(format, station)
    -- US National Oceanic and Atmospheric Administration
    --   * ICAO codes: http://www.rap.ucar.edu/weather/surface/stations.txt
    local noaa = "http://weather.noaa.gov/pub/data/observations/metar/decoded/"

    -- Get info from a weather station
    local f = io.popen("curl --connect-timeout 1 -fsm 3 "..noaa..station..".TXT")
    local ws = f:read("*all")
    f:close()

    -- Default values
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
    weather["{tempc}"]   = -- Temperature in celsius
      string.match(ws, "Temperature:[%s][%d%.]+[%s]F[%s]%(([%-]?[%d%.]+)[%s]C%)[%c]") or weather["{tempc}"]
    weather["{humid}"]   = -- Relative humidity in percent
      string.match(ws, "Relative[%s]Humidity:[%s]([%d]+)%%") or weather["{humid}"]
    weather["{press}"]   = -- Pressure in hPa
      string.match(ws, "Pressure[%s].+%((.+)[%s]hPa%)") or weather["{press}"]

    -- Wind speed in KMH if MPH was available
    if weather["{windmph}"] ~= "N/A" then
       weather["{windkmh}"] = math.floor(weather["{windmph}"] * 1.6)
    end

    return weather
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
