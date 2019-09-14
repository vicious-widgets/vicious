-- weather widget type fetching from from US NOAA
-- Copyright (C) 2010  Adrian C. <anrxc@sysphere.org>
-- Copyright (C) 2017  mutlusun <mutlusun@github.com>
-- Copyright (C) 2019  Arthur Axel 'fREW' Schmidt <git@frew.co>
-- Copyright (C) 2019  Nguyễn Gia Phong <vn.mcsinyx@gmail.com>
--
-- This file is part of Vicious.
--
-- Vicious is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as
-- published by the Free Software Foundation, either version 2 of the
-- License, or (at your option) any later version.
--
-- Vicious is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with Vicious.  If not, see <https://www.gnu.org/licenses/>.

-- {{{ Grab environment
local tonumber = tonumber
local math = { ceil = math.ceil }
local os = { date = os.date, difftime = os.difftime, time = os.time }
local string = { format = string.format }

local spawn = require"vicious.spawn"
local helpers = require"vicious.helpers"
-- }}}

-- Weather: provides weather information for a requested station
-- vicious.widgets.weather
local weather_all = {}

-- copied from http://lua-users.org/wiki/TimeZone
local function get_timezone_offset()
    local ts = os.time()
    local utcdate   = os.date("!*t", ts)
    local localdate = os.date("*t", ts)
    localdate.isdst = false -- this is the trick
    return os.difftime(os.time(localdate), os.time(utcdate))
end

-- {{{ Weather widget type
local function parse(stdout, stderr, exitreason, exitcode)
    -- Initialize function tables
    local _weather = {
        ["{city}"]    = "N/A",
        ["{when}"]    = "N/A",
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
    if stdout == '' then return _weather end

    _weather["{city}"]    = -- City and/or area
        stdout:match"^(.+)%,.*%([%u]+%)"
        or _weather["{city}"]
    _weather["{wind}"]    = -- Wind direction and degrees if available
        stdout:match"Wind:[%s][%a]+[%s][%a]+[%s](.+)[%s]at.+$"
        or _weather["{wind}"]
    _weather["{windmph}"] = -- Wind speed in MPH if available
        stdout:match"Wind:[%s].+[%s]at[%s]([%d]+)[%s]MPH"
        or _weather["{windmph}"]
    _weather["{sky}"]     = -- Sky conditions if available
        stdout:match"Sky[%s]conditions:[%s](.-)[%c]"
        or _weather["{sky}"]
    _weather["{weather}"] = -- Weather conditions if available
        stdout:match"Weather:[%s](.-)[%c]"
        or _weather["{weather}"]
    _weather["{tempf}"]   = -- Temperature in fahrenheit
        stdout:match"Temperature:[%s]([%-]?[%d%.]+).*[%c]"
        or _weather["{tempf}"]
    _weather["{dewf}"]    = -- Dew Point in fahrenheit
        stdout:match"Dew[%s]Point:[%s]([%-]?[%d%.]+).*[%c]"
        or _weather["{dewf}"]
    _weather["{humid}"]   = -- Relative humidity in percent
        stdout:match"Relative[%s]Humidity:[%s]([%d]+)%%"
        or _weather["{humid}"]
    _weather["{press}"]   = -- Pressure in hPa
        stdout:match"Pressure[%s].+%((.+)[%s]hPa%)"
        or _weather["{press}"]

    local year, month, day, hour, min =
        stdout:match"(%d%d%d%d).(%d%d).(%d%d) (%d%d)(%d%d) UTC"
    if year ~= nil then
        local utctable = { year = year, month = month, day = day,
                           hour = hour, min = min }
        _weather["{when}"] = os.time(utctable) + get_timezone_offset()
    end

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
    if not warg then return callback{} end

    -- Get weather forceast by the station ICAO code, from:
    -- * US National Oceanic and Atmospheric Administration
    local url = string.format(
        "https://tgftp.nws.noaa.gov/data/observations/metar/decoded/%s.TXT",
        warg)
    spawn.easy_async("curl -fs " .. url,
                     function (...) callback(parse(...)) end)
end
-- }}}

return helpers.setasyncall(weather_all)
