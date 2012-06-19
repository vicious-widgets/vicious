---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { gmatch = string.gmatch }
local helpers = require("vicious.helpers")
-- }}}


-- Mpd: provides Music Player Daemon information
-- vicious.widgets.mpd
local mpd = {}


-- {{{ MPD widget type
local function worker(format, warg)
    local mpd_state  = {
        ["{volume}"] = 0,
        ["{state}"]  = "N/A",
        ["{Artist}"] = "N/A",
        ["{Title}"]  = "N/A",
        ["{Album}"]  = "N/A",
        ["{Genre}"]  = "N/A",
        --["{Name}"] = "N/A",
        --["{file}"] = "N/A",
    }

    -- Fallback to MPD defaults
    local pass = warg and (warg.password or warg[1]) or "\"\""
    local host = warg and (warg.host or warg[2]) or "127.0.0.1"
    local port = warg and (warg.port or warg[3]) or "6600"

    -- Construct MPD client options
    local mpdh = "telnet://"..host..":"..port
    local echo = "echo 'password "..pass.."\nstatus\ncurrentsong\nclose'"

    -- Get data from MPD server
    local f = io.popen(echo.." | curl --connect-timeout 1 -fsm 3 "..mpdh)

    for line in f:lines() do
        for k, v in string.gmatch(line, "([%w]+):[%s](.*)$") do
            if     k == "volume" then mpd_state["{"..k.."}"] = v and tonumber(v)
            elseif k == "state"  then mpd_state["{"..k.."}"] = helpers.capitalize(v)
            elseif k == "Artist" then mpd_state["{"..k.."}"] = helpers.escape(v)
            elseif k == "Title"  then mpd_state["{"..k.."}"] = helpers.escape(v)
            elseif k == "Album"  then mpd_state["{"..k.."}"] = helpers.escape(v)
            elseif k == "Genre"  then mpd_state["{"..k.."}"] = helpers.escape(v)
            --elseif k == "Name" then mpd_state["{"..k.."}"] = helpers.escape(v)
            --elseif k == "file" then mpd_state["{"..k.."}"] = helpers.escape(v)
            end
        end
    end
    f:close()

    return mpd_state
end
-- }}}

return setmetatable(mpd, { __call = function(_, ...) return worker(...) end })
