---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local math = { ceil = math.ceil }
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
local wifiiw = {}


-- {{{ Variable definitions
local iw = "iw"
local iwcpaths = { "/sbin", "/usr/sbin", "/usr/local/sbin", "/usr/bin" }
-- }}}


-- {{{ Wireless widget type
local function worker(format, warg)
    if not warg then return end

    -- Default values
    local winfo = {
        ["{ssid}"] = "N/A",
        ["{mode}"] = "N/A",
        ["{chan}"] = 0,
        ["{rate}"] = 0,
        ["{freq}"] = 0,
		["{txpw}"] = 0,
		["{linp}"] = 0,
        ["{sign}"] = 0
    }

    -- Sbin paths aren't in user PATH, search for the binary
    if iw == "iw" then
        for _, p in ipairs(iwcpaths) do
            local f = io.open(p .. "/iw", "rb")
            if f then
                iw = p .. "/iw"
                f:close()
                break
            end
        end
    end

    -- Get data from iw where available
    local f = io.popen(iw .." dev ".. warg .. " link 2>&1;" .. iw .." dev ".. warg .. " info 2>&1")
    local iwresult = f:read("*all")
    f:close()

    -- iw wasn't found, isn't executable, or non-wireless interface
    if iwresult == nil or string.find(iwresult, "No such device") then
        return winfo
    end
	-- string match is simple in most cases, because iw uses a new line for every info
    winfo["{ssid}"] =  -- SSID can have almost anything in it until new line
      string.match(iwresult, 'SSID: ([^\n]*)') or winfo["{ssid}"]
    winfo["{mode}"] =  -- everything after 'type ' until new line
      string.match(iwresult, "type ([^\n]*)") or winfo["{mode}"]
    winfo["{chan}"] =  -- Channels are plain digits
      tonumber(string.match(iwresult, "channel ([%d]+)") or winfo["{chan}"])
    winfo["{rate}"] =  -- We don't want to display Mb/s
      tonumber(string.match(iwresult, "tx bitrate: ([%d%.]*)") or winfo["{rate}"])
    winfo["{freq}"] =  -- Frequency are plain digits
      tonumber(string.match(iwresult, "freq: ([%d]+)") or winfo["{link}"])
    winfo["{sign}"] =  -- Signal level can be a negative value, don't display decibel notation
      tonumber(string.match(iwresult, "signal: (%-[%d]+)") or winfo["{sign}"])
    winfo["{linp}"] =  -- Link Quality using the Windows definition (-50dBm->100%, -100dBm->0%)
      100 - ((winfo["{sign}"] * -2) - 100)
    winfo["{txpw}"] =  -- TX Power can be a negative value, don't display decibel notation
      tonumber(string.match(iwresult, "txpower ([%-]?[%d]+)") or winfo["{txpw}"])

    return winfo
end
-- }}}

return setmetatable(wifiiw, { __call = function(_, ...) return worker(...) end })
