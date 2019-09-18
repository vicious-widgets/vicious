-- contrib/mpc_all.lua
-- Copyright (C) 2009  Lucas de Vries <lucas@glacicle.com>
-- Copyright (C) 2010  Adrian C. <anrxc@sysphere.org>
-- Copyright (C) 2017  Jörg Thalheim <joerg@higgsboson.tk>
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
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { find = string.find }
local helpers = require("vicious.helpers")
-- }}}


-- Mpc: provides the currently playing song in MPD
-- vicious.contrib.mpc
local mpc_all = {}


-- {{{ MPC widget type
local function worker(format, warg)
    -- Get data from mpd
    local f = io.popen("mpc")
    local np = f:read("*line")
    f:close()

    -- Not installed,
    if np == nil or --  off         or                 stoppped.
       (string.find(np, "MPD_HOST") or string.find(np, "volume:"))
    then
        return {"Stopped"}
    end

    -- Check if we should scroll, or maybe truncate
    if warg then
        if type(warg) == "table" then
            np = helpers.scroll(np, warg[1], warg[2])
        else
            np = helpers.truncate(np, warg)
        end
    end

    return {np}
end
-- }}}

return setmetatable(mpc_all, { __call = function(_, ...) return worker(...) end })
