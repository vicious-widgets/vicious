---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local math = { floor = math.floor }
local type = type

local helpers = require"vicious.helpers"
local spawn = require"vicious.spawn"
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
local function format_progress(elapsed, duration)
    local em, es = math.floor(elapsed / 60), math.floor(elapsed % 60)
    local dm, ds = math.floor(duration / 60), math.floor(duration % 60)

    if dm < 10 then
        return ("%d:%02d"):format(em, es), ("%d:%02d"):format(dm, ds)
    elseif dm < 60 then
        return ("%02d:%02d"):format(em, es), ("%02d:%02d"):format(dm, ds)
    end

    local eh, dh = math.floor(em / 60), math.floor(dm / 60)
    em, dm = math.floor(em % 60), math.floor(dm % 60)
    if dm < 600 then
        return ("%d:%02d:%02d"):format(eh, em, es),
               ("%d:%02d:%02d"):format(dh, dm, ds)
    else
        return ("%02d:%02d:%02d"):format(eh, em, es),
               ("%02d:%02d:%02d"):format(dh, dm, ds)
    end
end
-- }}}

-- {{{ Format playing progress (percentage)
local function format_progress_percentage(elapsed, duration)
    if duration > 0 then
        local percentage = math.floor((elapsed / duration) * 100 + 0.5)
        return ("%d%%"):format(percentage)
    else
        return("0%")
    end
end
-- }}}

-- {{{ MPD widget type
function mpd_all.async(format, warg, callback)
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
    spawn.with_line_callback_with_shell(query .. "|" .. connect, {
        stdout = function (line)
            for k, v in line:gmatch"([%w]+):[%s](.*)$" do
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
        end,
        output_done = function ()
            -- Formatted elapsed and duration
            mpd_state["{Elapsed}"], mpd_state["{Duration}"] = format_progress(
                mpd_state["{elapsed}"], mpd_state["{duration}"])
            -- Formatted playing progress percentage
            mpd_state["{Progress}"] = format_progress_percentage(
                mpd_state["{elapsed}"], mpd_state["{duration}"])
            callback(mpd_state)
        end })
end
-- }}}

return helpers.setasyncall(mpd_all)
