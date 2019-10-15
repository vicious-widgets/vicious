-- notmuch_all - count messages that match a notmuch query
-- Copyright (C) 2019  Enric Morales <me@enric.me>
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
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General Public License
-- along with Vicious.  If not, see <https://www.gnu.org/licenses/>.

local tonumber = tonumber
local helpers = require("vicious.helpers")
local spawn = require("vicious.spawn")


local notmuch = {}

local function parse(stdout, stderr, exitreason, exitcode)
    local output = { count = "N/A" }
    if exitcode == 0 then output.count = tonumber(stdout) end
    return output
end

function notmuch.async(format, warg, callback)
    local cmd = ("notmuch count '^%s'"):format(warg)

    spawn.easy_async(cmd, function (...) callback(parse(...)) end)
end

return helpers.setasyncall(notmuch)
