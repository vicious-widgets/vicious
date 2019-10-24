-- widget type providing the subject of last e-mail in a mbox file
-- Copyright (C) 2010  Adrian C. <anrxc@sysphere.org>
-- Copyright (C) 2017  mutlusun <mutlusun@github.com>
-- Copyright (C) 2018  Nguyễn Gia Phong <vn.mcsinyx@gmail.com>
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
local io = { open = io.open }
local helpers = require("vicious.helpers")
-- }}}

-- Initialize variables
local subject = "N/A"

-- {{{ Mailbox widget type
return helpers.setcall(function (format, warg)
    if not warg then return end

    local f = io.open(type(warg) == "table" and warg[1] or warg)
    f:seek("end", -30720)
    -- mbox could be huge, get a 30kb chunk from EOF
    -- * attachment could be much bigger than 30kb
    local txt = f:read("*all")
    f:close()

    -- Find all Subject lines
    for i in txt:gmatch"Subject: ([^\n]*)" do subject = i end

    -- Check if we should scroll, or maybe truncate
    if type(warg) == "table" then
        if warg[3] ~= nil then
            subject = helpers.scroll(subject, warg[2], warg[3])
        else
            subject = helpers.truncate(subject, warg[2])
        end
    end

    return { subject }
end)
-- }}}
