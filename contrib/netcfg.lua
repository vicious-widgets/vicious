-- contrib/netcfg.lua
-- Copyright (C) 2010  Radu A. <admiral0@tuxfamily.org>
-- Copyright (C) 2010  Adrian C. (anrxc) <anrxc@sysphere.org>
-- Copyright (C) 2012  Arvydas Sidorenko <asido4@gmail.com>
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
local io = { popen = io.popen }
local setmetatable = setmetatable
local table = { insert = table.insert }
-- }}}


-- Netcfg: provides active netcfg network profiles
-- vicious.contrib.netcfg
local netcfg = {}


-- {{{ Netcfg widget type
local function worker(format)
    -- Initialize counters
    local profiles = {}

    local f = io.popen("ls -1 /var/run/network/profiles")
    for line in f:lines() do
        if line ~= nil then
            table.insert(profiles, line)
        end
    end
    f:close()

    return profiles
end
-- }}}

return setmetatable(netcfg, { __call = function(_, ...) return worker(...) end })
