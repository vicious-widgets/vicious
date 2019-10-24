-- hard drive temperatures widget type using hddtemp daemon
-- Copyright (C) 2010  Adrian C. <anrxc@sysphere.org>
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
local tonumber = tonumber

local helpers = require"vicious.helpers"
local spawn = require"vicious.spawn"
-- }}}

-- Hddtemp: provides hard drive temperatures using the hddtemp daemon
-- vicious.widgets.hddtemp
return helpers.setasyncall{
    async = function(format, warg, callback)
        if warg == nil then warg = 7634 end -- fallback to default hddtemp port
        local hdd_temp = {} -- get info from the hddtemp daemon
        spawn.with_line_callback_with_shell(
            "echo | curl -fs telnet://127.0.0.1:" .. warg,
            { stdout = function (line)
                  for d, t in line:gmatch"|([%/%w]+)|.-|(%d+)|[CF]|" do
                      hdd_temp["{"..d.."}"] = tonumber(t)
                  end
              end,
              output_done = function () callback(hdd_temp) end })
    end }
