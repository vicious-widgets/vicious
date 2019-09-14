-- volume widget type for GNU/Linux
-- Copyright (C) 2010  Adrian C. <anrxc@sysphere.org>
-- Copyright (C) 2017  Brandon Hartshorn <brandonhartshorn@gmail.com>
-- Copyright (C) 2017  mutlusun <mutlusun@github.com>
-- Copyright (C) 2019  Nguyễn Gia Phong <vn.mcsinyx@gmail.com>
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
local type = type
local tonumber = tonumber
local string = { match = string.match }
local table  = { concat = table.concat }

local helpers = require("vicious.helpers")
local spawn = require("vicious.spawn")
-- }}}

-- Volume: provides volume levels and state of requested ALSA mixers
-- vicious.widgets.volume
local volume_linux = {}

-- {{{ Volume widget type
local STATE = { on = '🔉', off = '🔈' }

local function parse(stdout, stderr, exitreason, exitcode)
    -- Capture mixer control state, e.g.        [  42    % ]   [  on    ]
    local volume, state = string.match(stdout, "%[([%d]+)%%%].*%[([%l]*)%]")
    -- Handle mixers without data
    if volume == nil then return {} end

    if state == "" and volume == "0"    -- handle mixers without mute
       or state == "off" then           -- handle muted mixers
        return { tonumber(volume), STATE.off }
    else
        return { tonumber(volume), STATE.on }
    end
end

function volume_linux.async(format, warg, callback)
    if not warg then return callback{} end
    if type(warg) ~= "table" then warg = { warg } end
    spawn.easy_async("amixer -M get " .. table.concat(warg, " "),
                     function (...) callback(parse(...)) end)
end
-- }}}

return helpers.setasyncall(volume_linux)
