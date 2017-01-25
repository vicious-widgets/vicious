---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2016, Marius M. <mellich@gmx.net>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local setmetatable = setmetatable
local helpers = require("vicious.helpers")
local io = {
    open  = io.open,
    popen = io.popen
}
local string = {
    find  = string.find,
    match = string.match
}
-- }}}


-- Wifiiw: provides wireless information for a requested interface using iw instead of deprecated iwconfig
-- vicious.widgets.wifiiw
local wifiiw_linux = {}


-- {{{ Wireless widget type
local function worker(format, warg)
    if not warg then return end

    -- Default values
    local winfo = {}

    -- Get data from iw where available
    local f = io.popen("export PATH=$PATH:/sbin/:/usr/sbin:/usr/local/sbin;" ..
					"iw dev ".. helpers.shellquote(tostring(warg)) .. " link 2>&1;" ..
					"iw dev ".. helpers.shellquote(tostring(warg)) .. " info 2>&1")
    local iwresult = f:read("*all")
    f:close()

    -- iw wasn't found, isn't executable, or non-wireless interface
    if iwresult == nil or string.find(iwresult, "No such device") then
        return winfo
    end
	-- string match is simple in most cases, because iw uses a new line for every info
    winfo["{ssid}"] =  -- SSID can have almost anything in it until new line
      string.match(iwresult, "SSID: ([^\n]*)") or "N/A"
    winfo["{mode}"] =  -- everything after 'type ' until new line
      string.match(iwresult, "type ([^\n]*)") or "N/A"
    winfo["{chan}"] =  -- Channels are plain digits
      tonumber(string.match(iwresult, "channel ([%d]+)") or 0)
    winfo["{rate}"] =  -- We don't want to display Mb/s
      tonumber(string.match(iwresult, "tx bitrate: ([%d%.]*)") or 0)
    winfo["{freq}"] =  -- Frequency are plain digits
      tonumber(string.match(iwresult, "freq: ([%d]+)") or 0)
    winfo["{sign}"] =  -- Signal level can be a negative value, don't display decibel notation
      tonumber(string.match(iwresult, "signal: (%-[%d]+)") or 0)
    winfo["{linp}"] =  -- Link Quality using the Windows definition (-50dBm->100%, -100dBm->0%)
      (winfo["{sign}"] ~= 0 and 100 - ((winfo["{sign}"] * -2) - 100) or 0)
    winfo["{txpw}"] =  -- TX Power can be a negative value, don't display decibel notation
      tonumber(string.match(iwresult, "txpower ([%-]?[%d]+)") or 0)

    return winfo
end
-- }}}

return setmetatable(wifiiw_linux, { __call = function(_, ...) return worker(...) end })
