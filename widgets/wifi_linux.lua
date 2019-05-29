---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local type = type
local tonumber = tonumber
local math = { floor = math.floor }

local helpers = require"vicious.helpers"
local spawn = require"vicious.spawn"
-- }}}


-- Wifi: provides wireless information for a requested interface using iwconfig
-- vicious.widgets.wifi
local wifi_linux = {}

-- {{{ Wireless widget type
local function parser(stdout, stderr, exitreason, exitcode)
    local winfo = {}
    -- Output differs from system to system, stats can be separated by
    -- either = or :. Some stats may not be supported by driver.
    -- SSID can have almost anything in it.
    winfo["{ssid}"] = stdout:match'ESSID[=:]"(.-)"' or "N/A"
    -- Modes are simple, but also match the "-" in Ad-Hoc
    winfo["{mode}"] = stdout:match"Mode[=:]([%w%-]+)" or "N/A"
    winfo["{chan}"] = tonumber(stdout:match"Channel[=:](%d+)" or 0)
    winfo["{rate}"] = -- Bitrate without unit (Mb/s)
        tonumber(stdout:match"Bit Rate[=:]%s?([%d%.]+)" or 0)
    winfo["{freq}"] = -- Frequency in MHz (is output always in GHz?)
        tonumber(stdout:match"Frequency[=:]%s?([%d%.]+)" or 0) * 1000
    winfo["{txpw}"] = -- Transmission power in dBm
        tonumber(stdout:match"Tx%-Power[=:](%d+)" or 0)
    winfo["{link}"] = -- Link quality over 70
        tonumber(stdout:match"Link Quality[=:](%d+)" or 0)
    winfo["{linp}"] = -- Link quality percentage if quality was available
        winfo["{link}"] ~= 0 and math.floor(winfo["{link}"]/0.7 + 0.5) or 0
    -- Signal level without unit (dBm), can be negative value
    winfo["{sign}"] = tonumber(stdout:match"Signal level[=:](%-?%d+)" or 0)
    return winfo
end

function wifi_linux.async(format, warg, callback)
    if type(warg) ~= "string" then return callback{} end
    spawn.easy_async_with_shell(
        "PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin iwconfig " .. warg,
        function (...) callback(parser(...)) end)
end
-- }}}

return helpers.setasyncall(wifi_linux)
