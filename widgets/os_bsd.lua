-- operating system widget type for *BSD
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
local los = { getenv = os.getenv }
local string = { match = string.match }
local helpers = require("vicious.helpers")
local spawn = require("vicious.spawn")
-- }}}

-- OS: provides operating system information
-- vicious.widgets.os
local os_bsd = {}

-- {{{ Operating system widget type
local function parse(stdout, stderr, exitreason, exitcode)
    local system = {
        ["ostype"]    = "N/A",
        ["hostname"]  = "N/A",
        ["osrelease"] = "N/A",
        ["username"]  = "N/A",
        ["entropy"]   = "N/A",
        ["entropy_p"] = "N/A"
    }

    -- BSD manual page: uname(1)
    system["ostype"], system["hostname"], system["osrelease"] =
        string.match(stdout, "([%w]+)[%s]([%w%p]+)[%s]([%w%p]+)")

    -- Get user from the environment
    system["username"] = los.getenv("USER")

    return {system["ostype"], system["osrelease"], system["username"],
            system["hostname"], system["entropy"], system["entropy_p"]}
end

function os_bsd.async(format, warg, callback)
    spawn.easy_async("uname -snr",
                     function (...) callback(parse(...)) end)
end
-- }}}

return helpers.setasyncall(os_bsd)
