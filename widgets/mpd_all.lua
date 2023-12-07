-- Music Player Daemon widget type
-- Copyright (C) 2010  Adrian C. <anrxc@sysphere.org>
-- Copyright (C) 2017,2019  mutlusun <mutlusun@github.com>
-- Copyright (C) 2018  Jörg Thalheim <joerg@thalheim.io>
-- Copyright (C) 2018-2019  Nguyễn Gia Phong <vn.mcsinyx@gmail.com>
-- Copyright (C) 2019  Juan Carlos Menonita <JuanKman94@users.noreply.github.com>
-- Copyright (C) 2019  Lorenzo Gaggini <lg@lgaggini.net>
-- Copyright (C) 2022  Constantin Piber <cp.piber@gmail.com>
-- Copyright (C) 2023  Cássio Ávila <cassioavila@autistici.org>
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

-- {{{ Build shell command from mpd command string
local function build_cmd(warg, q)
    -- Construct MPD client options, fallback to defaults when necessary
    local query = ("printf 'password %s\n%sclose\n'"):format(
        warg and (warg.password or warg[1]) or '""',
        q)
    local connect = ("curl --connect-timeout 1 -fsm 3 telnet://%s:%s"):format(
        warg and (warg.host or warg[2]) or "127.0.0.1",
        warg and (warg.port or warg[3]) or "6600")
    return query .. "|" .. connect
end
-- }}}

-- {{{ Common MPD commands
function mpd_all.playpause(warg)
    spawn.with_shell(build_cmd(warg, "pause\n"))
end
function mpd_all.play(warg)
    spawn.with_shell(build_cmd(warg, "pause 0\n"))
end
function mpd_all.pause(warg)
    spawn.with_shell(build_cmd(warg, "pause 1\n"))
end
function mpd_all.stop(warg)
    spawn.with_shell(build_cmd(warg, "stop\n"))
end
function mpd_all.next(warg)
    spawn.with_shell(build_cmd(warg, "next\n"))
end
function mpd_all.previous(warg)
    spawn.with_shell(build_cmd(warg, "previous\n"))
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
        ["{repeat}"]   = 0,
        ["{random}"]   = 0,
        ["{state}"]    = "N/A",
        ["{Artist}"]   = "N/A",
        ["{Artists}"]  = "N/A",
        ["{Title}"]    = "N/A",
        ["{Album}"]    = "N/A",
        ["{Genre}"]    = "N/A",
        ["{Genres}"]   = "N/A",
    }

    local separator = warg and (warg.separator or warg[4]) or ", "

    local cmd = build_cmd(warg, "status\ncurrentsong\n")

    local function append_with_separator (current, value)
        return ("%s%s%s"):format(current, separator, value)
    end

    -- Get data from MPD server
    spawn.with_line_callback_with_shell(cmd, {
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
                       k == "Album" or k == "Genre" then
                    if k == "Artist" or k == "Genre" then
                        local current_key = "{" .. k .. "s}"
                        local current_state = mpd_state[current_key]
                        if current_state == "N/A" then
                            mpd_state[current_key] = v
                        else
                            mpd_state[current_key] = append_with_separator(
                                current_state, v)
                        end
                    end
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
