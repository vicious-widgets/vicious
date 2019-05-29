---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2016, Marius M. <mellich@gmx.net>
---------------------------------------------------

-- {{{ Grab environment
local type = type
local tonumber = tonumber

local helpers = require("vicious.helpers")
local spawn = require("vicious.spawn")
-- }}}


-- Wifiiw: provides wireless information for a requested interface
-- using iw instead of deprecated iwconfig
-- vicious.widgets.wifiiw
local wifiiw_linux = {}

local LINK = "PATH=$PATH:/sbin/:/usr/sbin:/usr/local/sbin iw dev %s link"
local INFO = "PATH=$PATH:/sbin/:/usr/sbin:/usr/local/sbin iw dev %s info"

-- {{{ Wireless widget type
function wifiiw_linux.async(format, warg, callback)
    if type(warg) ~= "string" then return callback{} end
    local winfo = {}

    local function parse_link(stdout)
        winfo["{ssid}"] = stdout:match"SSID: ([^\n]*)" or "N/A"
        winfo["{freq}"] = tonumber(stdout:match"freq: (%d+)" or 0)
        winfo["{sign}"] = -- Signal level can be negative; w/o unit (dBm)
            tonumber(stdout:match"signal: (%-?%d+)" or 0)
        winfo["{linp}"] = -- Link Quality (-100dBm->0%, -50dBm->100%)
            winfo["{sign}"] ~= 0 and 200 + winfo["{sign}"]*2 or 0
        winfo["{rate}"] = -- Transmission rate, without unit (Mb/s)
            tonumber(stdout:match"tx bitrate: ([%d%.]+)" or 0)
    end

    local function parse_info(stdout)
        winfo["{mode}"] = stdout:match"type ([^\n]*)" or "N/A"
        winfo["{chan}"] = tonumber(stdout:match"channel (%d+)" or 0)
        -- Transmission power, without unit (dBm)
        winfo["{txpw}"] = tonumber(stdout:match"txpower (%-?%d+)" or 0)
    end

    spawn.easy_async_with_shell(
        LINK:format(warg),
        function (stdout, stderr, exitreason, exitcode)
            parse_link(stdout)
            spawn.easy_async_with_shell(
                INFO:format(warg),
                function (stdout, stderr, exitreason, exitcode)
                    parse_info(stdout)
                    callback(winfo)
                end)
        end)
end
-- }}}

return helpers.setasyncall(wifiiw_linux)
