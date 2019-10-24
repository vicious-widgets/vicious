-- widget type providing the count of total, old and new messages in mbox files
-- Copyright (C) 2010  Adrian C. <anrxc@sysphere.org>
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
local io = { open = io.open }
local helpers = require"vicious.helpers"
-- }}}

-- {{{ Mbox count widget type
return helpers.setcall(function (format, warg)
    if not warg then return end

    -- Initialize counters
    local count = { old = 0, total = 0, new = 0 }

    -- Get data from mbox files
    for i=1, #warg do
        local f = io.open(warg[i])

        while true do
            -- Read the mbox line by line, if we are going to read
            -- some *HUGE* folders then switch to reading chunks
            local lines = f:read("*line")
            if not lines then break end

            -- Find all messages
            --  * http://www.jwz.org/doc/content-length.html
            local _, from = lines:find"^From[%s]"
            if from ~= nil then count.total = count.total + 1 end

            -- Read messages have the Status header
            local _, status = lines:find"^Status:[%s]RO$"
            if status ~= nil then count.old = count.old + 1 end

            -- Skip the folder internal data
            local _, int = lines:find"^Subject:[%s].*FOLDER[%s]INTERNAL[%s]DATA"
            if int ~= nil then count.total = count.total - 1 end
        end
        f:close()
    end

    -- Substract total from old to get the new count
    count.new = count.total - count.old

    return {count.total, count.old, count.new}
end)
-- }}}
