-- volume widget type for FreeBSD
-- Copyright (C) 2017,2019  mutlusun <mutlusun@github.com>
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
local tonumber = tonumber
local string = { match = string.match }
local helpers = require("vicious.helpers")
local spawn = require("vicious.spawn")
-- }}}

-- Volume: provides volume levels and state of requested mixer
-- vicious.widgets.volume_freebsd
local volume_freebsd = {}

-- {{{ Volume widget type
local STATE = { on = '🔉', off = '🔈' }

local function parse(stdout, stderr, exitreason, exitcode)
    -- Capture mixer control state, e.g.       42   :  42
    local voll, volr = string.match(stdout, "([%d]+):([%d]+)\n$")
    if voll == "0" and volr == "0" then return { 0, 0, STATE.off } end
    return { tonumber(voll), tonumber(volr), STATE.on }
end

function volume_freebsd.async(format, warg, callback)
    if not warg then return callback{} end
    spawn.easy_async("mixer " .. helpers.shellquote(warg),
                     function (...) callback(parse(...)) end)
end
-- }}}

return helpers.setasyncall(volume_freebsd)
