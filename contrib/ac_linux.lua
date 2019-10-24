-- contrib/ac_linux.lua
-- Copyright (C) 2012  jinleileiking <jinleileiking@gmail.com>
-- Copyright (C) 2017  Jörg Thalheim <joerg@higgsboson.tk>
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
local setmetatable = setmetatable
local string = { format = string.format }
local helpers = require("vicious.helpers")
local math = {
    min = math.min,
    floor = math.floor
}
-- }}}

local ac_linux = {}

-- {{{ AC widget type
local function worker(format, warg)
    local ac = helpers.pathtotable("/sys/class/power_supply/"..warg)

    local state = ac.online
    if state == nil then
        return {"N/A"}
    elseif state == "1\n" then
        return {"On"}
    else
        return {"Off"}
    end
end
-- }}}


return setmetatable(ac_linux, { __call = function(_, ...) return worker(...) end })
