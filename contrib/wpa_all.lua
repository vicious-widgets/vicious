-- contrib/wpa_all.lua
-- Copyright (C) 2012  jinleileiking <jinleileiking@gmail.com>
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
local math = { ceil = math.ceil }
local setmetatable = setmetatable
local helpers = require("vicious.helpers")
local io = {
    open = io.open,
    popen = io.popen
}
local string = {
    find = string.find,
    match = string.match
}
-- }}}


-- Wifi: provides wireless information for a requested interface
local wpa_all = {}

local info = {
  ["{ssid}"] = "N/A",
  ["{bssid}"]  = "N/A",
  ["{ip}"]  = "N/A",
  ["{qual}"]  = "N/A",
}

-- {{{ Wireless widget type
local function worker(format, warg)
    if not warg then return info end

    local wpa_cmd = "wpa_cli -i'" .. warg ..  "' status 2>&1"
    local f = io.popen(wpa_cmd)
    local output = f:read("*all")
    f:close()

    if not output then return info end

    state = string.match(output, 'wpa_state=([%a]+)') or 'N/A'
    info["{bssid}"] = string.match(output, 'bssid=([%d%a:]+)') or 'N/A'
    info["{ssid}"] = string.match(output, 'ssid=([%a]+)') or 'N/A'
    info["{ip}"] = string.match(output, 'ip_address=([%d.]+)') or 'N/A'

    if not state == 'COMPLETED' then
        return info
    end

    local wpa_cmd = "wpa_cli -i'" .. warg ..  "' bss " .. bssid .. " 2>&1"
    local f = io.popen(wpa_cmd)
    local output = f:read("*all")
    f:close()

    if not output then return info end

    info["{qual}"] = string.match(output, 'qual=([%d]+)')

    return info
end
-- }}}

return setmetatable(wpa_all, { __call = function(_, ...) return worker(...) end })
