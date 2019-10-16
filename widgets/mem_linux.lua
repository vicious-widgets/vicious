-- RAM and swap usage widget type for GNU/Linux
-- Copyright (C) 2010  Adrian C. <anrxc@sysphere.org>
-- Copyright (C) 2009  Lucas de Vries <lucas@glacicle.com>
-- Copyright (C) 2017  mutlusun <mutlusun@github.com>
-- Copyright (C) 2018  Jay Kamat <jaygkamat@gmail.com>
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
local math = { floor = math.floor }
local string = { gmatch = string.gmatch }
local helpers = require"vicious.helpers"
-- }}}

-- {{{ Memory widget type
return helpers.setcall(function ()
    local _mem = { buf = {}, swp = {} }

    -- Get MEM info
    for line in io.lines("/proc/meminfo") do
        for k, v in string.gmatch(line, "([%a]+):[%s]+([%d]+).+") do
            if     k == "MemTotal"  then _mem.total = math.floor(v/1024)
            elseif k == "MemFree"   then _mem.buf.f = math.floor(v/1024)
            elseif k == "MemAvailable" then _mem.buf.a = math.floor(v/1024)
            elseif k == "Buffers"   then _mem.buf.b = math.floor(v/1024)
            elseif k == "Cached"    then _mem.buf.c = math.floor(v/1024)
            elseif k == "SwapTotal" then _mem.swp.t = math.floor(v/1024)
            elseif k == "SwapFree"  then _mem.swp.f = math.floor(v/1024)
            end
        end
    end

    -- Calculate memory percentage
    _mem.free  = _mem.buf.a
    _mem.inuse = _mem.total - _mem.free
    _mem.bcuse = _mem.total - _mem.buf.f
    _mem.usep  = math.floor(_mem.inuse / _mem.total * 100)
    -- Calculate swap percentage
    _mem.swp.inuse = _mem.swp.t - _mem.swp.f
    _mem.swp.usep  = math.floor(_mem.swp.inuse / _mem.swp.t * 100)

    return {_mem.usep,     _mem.inuse,     _mem.total, _mem.free,
            _mem.swp.usep, _mem.swp.inuse, _mem.swp.t, _mem.swp.f,
            _mem.bcuse }
end)
-- }}}
