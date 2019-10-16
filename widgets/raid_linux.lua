-- widget type providing RAID array information on GNU/Linux
-- Copyright (C) 2010  Hagen Schink <troja84@googlemail.com>
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
local string = {
    len = string.len,
    sub = string.sub,
    match = string.match,
    gmatch = string.gmatch
}

local helpers = require"vicious.helpers"
-- }}}

-- Initialize function tables
local mddev = {}

-- {{{ RAID widget type
return helpers.setcall(function (format, warg)
    if not warg then return end
    mddev[warg] = {
        ["found"]    = false,
        ["active"]   = 0,
        ["assigned"] = 0
    }

    -- Linux manual page: md(4)
    local f = io.open("/proc/mdstat")
    for line in f:lines() do
        if mddev[warg]["found"] then
            local updev = string.match(line, "%[[_U]+%]")

            for _ in string.gmatch(updev, "U") do
                mddev[warg]["active"] = mddev[warg]["active"] + 1
            end

            break
        elseif string.sub(line, 1, string.len(warg)) == warg then
            mddev[warg]["found"] = true

            for _ in string.gmatch(line, "%[[%d]%]") do
                mddev[warg]["assigned"] = mddev[warg]["assigned"] + 1
            end
        end
    end
    f:close()

    return {mddev[warg]["assigned"], mddev[warg]["active"]}
end)
-- }}}
