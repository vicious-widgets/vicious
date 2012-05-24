---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2012, jinleileiking. <jinleileiking@gmail.com>
---------------------------------------------------

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
module("vicious.contrib.wpa")


-- {{{ Wireless widget type
local function worker(format, warg)
    if not warg then return end

    local wpa_cmd = "/usr/bin/wpa_cli -i" .. warg ..  " status 2>&1"
    local f = io.popen(wpa_cmd)
    local output = f:read("*all")
    f:close()

    bssid = string.match(output, 'bssid=([%d:]+)')
    ssid = string.match(output, 'ssid=([%a]+)')

    local wpa_cmd = "/usr/bin/wpa_cli -i" .. warg ..  " bss " .. bssid .. " 2>&1"
    local f = io.popen(wpa_cmd)
    local output = f:read("*all")

    qual = string.match(output, 'qual=([%d]+)')

    return {ssid, qual}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
