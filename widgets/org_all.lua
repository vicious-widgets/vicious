-- widget type providing agenda from Emacs org-mode
-- Copyright (C) 2010  Adrian C. <anrxc@sysphere.org>
-- Copyright (C) 2010  org-awesome, Damien Leone
-- Copyright (C) 2017  mutlusun <mutlusun@github.com>
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
local io = { lines = io.lines }
local os = { time = os.time, date = os.date }
local helpers = require"vicious.helpers"
-- }}}

-- {{{ OrgMode widget type
return helpers.setcall(function (format, warg)
    if not warg then return end

    -- Compute delays
    local today  = os.time{ year = os.date("%Y"), month = os.date("%m"),
    day = os.date("%d") }
    local soon   = today + 24*3600*3  -- 3 days ahead is close
    local future = today + 24*3600*7  -- 7 days ahead is maximum

    -- Initialize counters
    local count = { past = 0, today = 0, soon = 0, future = 0 }

    -- Get data from agenda files
    for i = 1,#warg do
        for line in io.lines(warg[i]) do
            local scheduled = line:find"SCHEDULED:"
            local deadline = line:find"DEADLINE:"
            local closed = line:find"CLOSED:"
            local b, _, y, m, d = line:find"(%d%d%d%d)-(%d%d)-(%d%d)"

            if (scheduled or deadline) and not closed and b then
                local t = os.time{ year = y, month = m, day = d }
                if t < today then
                    count.past = count.past + 1
                elseif t == today then
                    count.today = count.today + 1
                elseif t <= soon then
                    count.soon = count.soon + 1
                elseif t <= future then
                    count.future = count.future + 1
                end
            end
        end
    end

    return { count.past, count.today, count.soon, count.future }
end)
-- }}}
