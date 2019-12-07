-- widget type providing number of new and unread Maildir messages
-- Copyright (C) 2010  Adrian C. <anrxc@sysphere.org>
-- Copyright (C) 2010  Fredrik Ax
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

local helpers = require"vicious.helpers"
local spawn = require"vicious.spawn"
-- }}}

-- vicious.widgets.mdir
local mdir_all = {}

-- {{{ Maildir widget type
function mdir_all.async(format, warg, callback)
    if type(warg) ~= "table" then return callback{} end
    local starting_points = ""
    for _,dir in ipairs(warg) do
        starting_points = starting_points .. " " .. helpers.shellquote(dir)
    end
    if starting_points == "" then return callback{ 0, 0 } end

    local new, cur = 0, 0
    spawn.with_line_callback(
        "find" .. starting_points .. " -type f -regex '.*/cur/.*2,[^S]*$'",
        { stdout = function (filename) cur = cur + 1 end,
          output_done = function ()
              spawn.with_line_callback(
                  "find" .. starting_points .. " -type f -path '*/new/*'",
                  { stdout = function (filename) new = new + 1 end,
                    output_done = function () callback{ new, cur } end })
          end })
end
-- }}}

return helpers.setasyncall(mdir_all)
