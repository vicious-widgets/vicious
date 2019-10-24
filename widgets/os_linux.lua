-- operating system widget type for GNU/Linux
-- Copyright (C) 2010  Adrian C. <anrxc@sysphere.org>
-- Copyright (C) 2019  Nguyễn Gia Phong <vn.mcsinyx@gmail.com>
-- Copyright (C) 2019  mutlusun <mutlusun@users.noreply.github.com>
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
local pairs = pairs
local tonumber = tonumber
local math = { ceil = math.ceil }
local los = { getenv = os.getenv }
local string = { gsub = string.gsub }

local helpers = require"vicious.helpers"
-- }}}

-- {{{ Operating system widget type
return helpers.setcall(function ()
    local system = {
        ["ostype"]    = "N/A",
        ["hostname"]  = "N/A",
        ["osrelease"] = "N/A",
        ["username"]  = "N/A",
        ["entropy"]   = "N/A",
        ["entropy_p"] = "N/A"
    }

    -- Linux manual page: uname(2)
    local kernel = helpers.pathtotable("/proc/sys/kernel")
    for k, _ in pairs(system) do
        if kernel[k] then
            system[k] = string.gsub(kernel[k], "[%s]*$", "")
        end
    end

    -- Linux manual page: random(4)
    if kernel.random then
        -- Linux 2.6 default entropy pool is 4096-bits
        local poolsize = tonumber(kernel.random.poolsize)

        -- Get available entropy and calculate percentage
        system["entropy"]   = tonumber(kernel.random.entropy_avail)
        system["entropy_p"] = math.ceil(system["entropy"] * 100 / poolsize)
    end

    -- Get user from the environment
    system["username"] = los.getenv("USER")

    return {system["ostype"], system["osrelease"], system["username"],
            system["hostname"], system["entropy"], system["entropy_p"]}
end)
-- }}}
