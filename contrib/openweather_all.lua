-- contrib/openweather_all.lua
-- Copyright (C) 2013  NormalRa <normalrawr gmail com>
-- Copyright (C) 2017  Jörg Thalheim <joerg@higgsboson.tk>
-- Copyright (C) 2020  Marcel Arpogaus <marcel.arpogaus gmail com>
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
local string = {match = string.match}
local math = {ceil = math.ceil, floor = math.floor}
local helpers = require "vicious.helpers"
local spawn = require "vicious.spawn"
-- }}}

-- Openweather: provides weather information for a requested station
-- vicious.widgets.openweather
local openweather_all = {}

-- Initialize function tables
local _wdirs = {"N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"}
local _wdata = {
    ["{city}"] = "N/A",
    ["{wind deg}"] = "N/A",
    ["{wind aim}"] = "N/A",
    ["{wind mps}"] = "N/A",
    ["{wind kmh}"] = "N/A",
    ["{sky}"] = "N/A",
    ["{weather}"] = "N/A",
    ["{temp c}"] = "N/A",
    ["{temp min c}"] = "N/A",
    ["{temp max c}"] = "N/A",
    ["{sunrise}"] = -1,
    ["{sunset}"] = -1,
    ["{humid}"] = "N/A",
    ["{press}"] = "N/A"
}

-- {{{ Openweather widget type
local function parse(stdout, stderr, exitreason, exitcode)
    -- Check if there was a timeout or a problem with the station
    if stdout == nil or exitcode ~= 0 then return _wdata end

    _wdata["{city}"] = -- City name
    string.match(stdout, '"name":"([%a%s%-]+)"') or _wdata["{city}"]
    _wdata["{wind deg}"] = -- Wind degrees
    string.match(stdout, '"deg":([%d]+)') or _wdata["{wind deg}"]
    _wdata["{wind mps}"] = -- Wind speed in meters per second
    string.match(stdout, '"speed":([%d%.]+)') or _wdata["{wind mps}"]
    _wdata["{sky}"] = -- Sky conditions
    string.match(stdout, '"main":"([%a]+)"') or _wdata["{sky}"]
    _wdata["{weather}"] = -- Weather description
    string.match(stdout, '"description":"([%a%s]+)"') or _wdata["{weather}"]
    _wdata["{temp c}"] = -- Temperature in celsius
    string.match(stdout, '"temp":([%-]?[%d%.]+)') or _wdata["{temp c}"]
    _wdata["{temp min c}"] = -- Minimal Temperature in celsius
    string.match(stdout, '"temp_min":([%-]?[%d%.]+)') or _wdata["{temp min c}"]
    _wdata["{temp max c}"] = -- Maximal Temperature in celsius
    string.match(stdout, '"temp_max":([%-]?[%d%.]+)') or _wdata["{temp max c}"]
    _wdata["{humid}"] = -- Relative humidity in percent
    string.match(stdout, '"humidity":([%d]+)') or _wdata["{humid}"]
    _wdata["{sunrise}"] = -- Sunrise
    tonumber(string.match(stdout, '"sunrise":([%d]+)')) or _wdata["{sunrise}"]
    _wdata["{sunset}"] = -- Sunset
    tonumber(string.match(stdout, '"sunset":([%d]+)')) or _wdata["{sunset}"]
    _wdata["{press}"] = -- Pressure in hPa
    string.match(stdout, '"pressure":([%d%.]+)') or _wdata["{press}"]

    -- Wind speed in km/h
    if _wdata["{wind mps}"] ~= "N/A" then
        _wdata["{wind mps}"] = math.floor(tonumber(_wdata["{wind mps}"]) + .5)
        _wdata["{wind kmh}"] = math.ceil(_wdata["{wind mps}"] * 3.6)
    end -- Temperature in °C
    if _wdata["{temp c}"] ~= "N/A" then
        _wdata["{temp c}"] = math.floor(tonumber(_wdata["{temp c}"]) + .5)
    end -- Calculate wind direction
    if _wdata["{wind deg}"] ~= "N/A" then
        _wdata["{wind deg}"] = tonumber(_wdata["{wind deg}"])

        -- Lua tables start at [1]
        if (_wdata["{wind deg}"] / 45) % 1 == 0 then
            _wdata["{wind aim}"] = _wdirs[_wdata["{wind deg}"] / 45 + 1]
        else
            _wdata["{wind aim}"] = _wdirs[math.ceil(_wdata["{wind deg}"] / 45) +
                                       1] ..
                                       _wdirs[math.floor(
                                           _wdata["{wind deg}"] / 45) + 1]
        end
    end

    return _wdata
end

function openweather_all.async(format, warg, callback)
    if not warg then return callback {} end
    if type(warg) ~= "table" then return callback {} end

    -- Get weather forceast using the city ID code, from:
    -- * OpenWeatherMap.org
    local openweather = "http://api.openweathermap.org/data/2.5/weather?id=" ..
                            warg.city_id .. "&appid=" .. warg.app_id ..
                            "&mode=json&units=metric"

    spawn.easy_async("curl --connect-timeout 1 -fsm 3 '" .. openweather .. "'",
                     function(...) callback(parse(...)) end)
end
-- }}}

return helpers.setasyncall(openweather_all)
