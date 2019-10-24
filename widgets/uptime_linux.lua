-- uptime widget type for GNU/Linux
-- Copyright (C) 2009  Lucas de Vries <lucas@glacicle.com>
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
local math = { floor = math.floor }
local string = { match = string.match }
local helpers = require("vicious.helpers")
-- }}}

-- {{{ Uptime widget type
return helpers.setcall(function ()
    local proc = helpers.pathtotable("/proc")

    -- Get system uptime
    local up_t = math.floor(string.match(proc.uptime, "[%d]+"))
    local up_d = math.floor(up_t   / (3600 * 24))
    local up_h = math.floor((up_t  % (3600 * 24)) / 3600)
    local up_m = math.floor(((up_t % (3600 * 24)) % 3600) / 60)

    local l1, l5, l15 = -- Get load averages for past 1, 5 and 15 minutes
        string.match(proc.loadavg, "([%d%.]+)[%s]([%d%.]+)[%s]([%d%.]+)")
    return {up_d, up_h, up_m, l1, l5, l15}
end)
-- }}}
