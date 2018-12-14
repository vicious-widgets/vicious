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
local mpd_all = {}


-- {{{ Return true if number is nonzero
local function cbool(number)
    return type(number) == "number" and number ~= 0 or number
end
-- }}}

-- {{{ Format playing progress
function format_progress(elapsed, duration)
    local em, es = elapsed / 60, elapsed % 60
    local dm, ds = duration / 60, duration % 60

    if dm < 10 then
        return ("%d:%02d"):format(em, es), ("%d:%02d"):format(dm, ds)
    elseif dm < 60 then
        return ("%02d:%02d"):format(em, es), ("%02d:%02d"):format(dm, ds)
    elseif dm < 600 then
        return ("%d:%02d:%02d"):format(em / 60, em % 60, es),
               ("%d:%02d:%02d"):format(dm / 60, dm % 60, ds)
    else
        return ("%02d:%02d:%02d"):format(em / 60, em % 60, es),
               ("%02d:%02d:%02d"):format(dm / 60, dm % 60, ds)
    end
end
-- }}}

-- {{{ MPD widget type
local function worker(format, warg)
    -- Fallback values
    local mpd_state = {
        ["{volume}"]   = 0,
        ["{bitrate}"]  = 0,
        ["{elapsed}"]  = 0,
        ["{duration}"] = 0,
        ["{repeat}"]   = false,
        ["{random}"]   = false,
        ["{state}"]    = "N/A",
        ["{Artist}"]   = "N/A",
        ["{Title}"]    = "N/A",
        ["{Album}"]    = "N/A",
        ["{Genre}"]    = "N/A",
        --["{Name}"]   = "N/A",
        --["{file}"]   = "N/A",
    }

    -- Construct MPD client options, fallback to defaults when necessary
    local query = ("printf 'password %s\nstatus\ncurrentsong\nclose\n'"):format(
        warg and (warg.password or warg[1]) or '""')
    local connect = ("curl --connect-timeout 1 -fsm 3 telnet://%s:%s"):format(
        warg and (warg.host or warg[2]) or "127.0.0.1",
        warg and (warg.port or warg[3]) or "6600")

    -- Get data from MPD server
    local f = io.popen(query .. "|" .. connect)
    for line in f:lines() do
        for k, v in string.gmatch(line, "([%w]+):[%s](.*)$") do
            local key = "{" .. k .. "}"
            if k == "volume" or k == "bitrate" or
               k == "elapsed" or k == "duration" then
                mpd_state[key] = v and tonumber(v)
            elseif k == "repeat" or k == "random" then
                mpd_state[key] = cbool(v)
            elseif k == "state" then
                mpd_state[key] = helpers.capitalize(v)
            elseif k == "Artist" or k == "Title" or
                   --k == "Name" or k == "file" or
                   k == "Album" or k == "Genre" then
                mpd_state[key] = v
            end
        end
    end
    f:close()

    -- Formatted elapsed and duration
    mpd_state["{Elapsed}"], mpd_state["{Duration}"] = format_progress(
        mpd_state["{elapsed}"], mpd_state["{duration}"])

    return mpd_state
end
-- }}}

return setmetatable(mpd_all, { __call = function(_, ...) return worker(...) end })
