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

    na = {'N/A', 'N/A', 'N/A', 'N/A'}
    if not warg then return na end

    local f = io.popen("which wpa_cli")
    local wpa_cli = f:read("*all")
    f:close()

    wpa_cli = string.match(wpa_cli, '([%a/_]+)')

    local wpa_cmd = wpa_cli .. " -i" .. warg ..  " status 2>&1"
    local f = io.popen(wpa_cmd)
    local output = f:read("*all")
    f:close()

    if not output then return na end

    state = string.match(output, 'wpa_state=([%a]+)') or 'N/A'
    bssid = string.match(output, 'bssid=([%d%a:]+)') or 'N/A'
    ssid = string.match(output, 'ssid=([%a]+)') or 'N/A'
    ip = string.match(output, 'ip_address=([%d.]+)') or 'N/A'

    if not state == 'COMPLETED' then 
        return na
    end

    local wpa_cmd = wpa_cli .. " -i" .. warg ..  " bss " .. bssid .. " 2>&1"
    local f = io.popen(wpa_cmd)
    local output = f:read("*all")
    f:close()

    if not output then return na end

    qual = string.match(output, 'qual=([%d]+)')

    return {ssid, qual, ip, bssid}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
