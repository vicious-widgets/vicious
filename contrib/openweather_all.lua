-- contrib/openweather_all.lua
-- Copyright (C) 2013  NormalRa <normalrawr gmail com>
-- Copyright (C) 2017  Jörg Thalheim <joerg@higgsboson.tk>
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
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { match = string.match }
local math = {
    ceil = math.ceil,
    floor = math.floor
}
-- }}}


-- Openweather: provides weather information for a requested station
-- vicious.widgets.openweather
local openweather_all = {}


-- Initialize function tables
local _wdirs = { "N", "NE", "E", "SE", "S", "SW", "W", "NW", "N" }
local _wdata = {
    ["{city}"]      = "N/A",
    ["{wind deg}"]  = "N/A",
    ["{wind aim}"]  = "N/A",
    ["{wind mps}"]  = "N/A",
    ["{wind kmh}"]  = "N/A",
    ["{sky}"]       = "N/A",
    ["{weather}"]   = "N/A",
    ["{temp c}"]    = "N/A",
    ["{humid}"]     = "N/A",
    ["{press}"]     = "N/A"
}

-- {{{ Openweather widget type
local function worker(format, warg)
    if not warg then return end

    -- Get weather forceast using the city ID code, from:
    -- * OpenWeatherMap.org
    local openweather = "http://api.openweathermap.org/data/2.5/weather?id="..warg.."&mode=json&units=metric"
    local f = io.popen("curl --connect-timeout 1 -fsm 3 '"..openweather.."'")
    local ws = f:read("*all")
    f:close()

    -- Check if there was a timeout or a problem with the station
    if ws == nil then return _wdata end

    _wdata["{city}"]     = -- City name
        string.match(ws, '"name":"([%a%s%-]+)"') or _wdata["{city}"]
    _wdata["{wind deg}"] = -- Wind degrees
        string.match(ws, '"deg":([%d]+)') or _wdata["{wind deg}"]
    _wdata["{wind mps}"]  = -- Wind speed in meters per second
        string.match(ws, '"speed":([%d%.]+)') or _wdata["{wind mps}"]
    _wdata["{sky}"]      = -- Sky conditions
        string.match(ws, '"main":"([%a]+)"') or _wdata["{sky}"]
    _wdata["{weather}"]  = -- Weather description
        string.match(ws, '"description":"([%a%s]+)"') or _wdata["{weather}"]
    _wdata["{temp c}"]    = -- Temperature in celsius
        string.match(ws, '"temp":([%-]?[%d%.]+)') or _wdata["{temp c}"]
    _wdata["{humid}"]    = -- Relative humidity in percent
        string.match(ws, '"humidity":([%d]+)') or _wdata["{humid}"]
    _wdata["{press}"]    = -- Pressure in hPa
        string.match(ws, '"pressure":([%d%.]+)') or _wdata["{press}"]

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
        if (_wdata["{wind deg}"] / 45)%1 == 0 then
            _wdata["{wind aim}"] = _wdirs[_wdata["{wind deg}"] / 45 + 1]
        else
            _wdata["{wind aim}"] =
                _wdirs[math.ceil(_wdata["{wind deg}"] / 45) + 1]..
                _wdirs[math.floor(_wdata["{wind deg}"] / 45) + 1]
        end
    end

    return _wdata
end
-- }}}

return setmetatable(openweather_all, { __call = function(_, ...) return worker(...) end })
