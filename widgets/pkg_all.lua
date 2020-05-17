-- widget type providing number of pending updates
-- Copyright (C) 2010  Adrian C. <anrxc@sysphere.org>
-- Copyright (C) 2017  Joerg Thalheim <joerg@thalheim.io>
-- Copyright (C) 2017  getzze <getzze@gmail.com>
-- Copyright (C) 2017  mutlusun <mutlusun@github.com>
-- Copyright (C) 2019  Nguyễn Gia Phong <vn.mcsinyx@gmail.com>
-- Copyright (C) 2020  Elmeri Niemelä <niemela.elmeri@gmail.com>
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
local spawn = require("vicious.spawn")
local helpers = require("vicious.helpers")
-- }}}

-- Pkg: provides number of pending updates on UNIX systems
-- vicious.widgets.pkg
local pkg_all = {}

local PKGMGR = {
    ["Arch"] = { cmd = "pacman -Qu", sub = 0 },
    ["Arch C"] = { cmd = "checkupdates", sub = 0 },
    ["Arch S"] = { cmd = "yes | pacman -Sup", sub = 1 },
    ["Debian"] = { cmd = "apt list --upgradable", sub = 1 },
    ["Ubuntu"] = { cmd = "apt list --upgradable", sub = 1 },
    ["Fedora"] = { cmd = "dnf check-update", sub = 2 },
    ["FreeBSD"] = { cmd = "pkg version -I -l '<'", sub = 0 },
    ["Mandriva"] = { cmd = "urpmq --auto-select", sub = 0 }
}

-- {{{ Packages widget type
function pkg_all.async(format, warg, callback)
    if not warg then return callback{} end
    local pkgmgr = PKGMGR[warg]

    local size, lines = -pkgmgr.sub, ""
    spawn.with_line_callback_with_shell(pkgmgr.cmd, {
        stdout = function (str)
            size = size + 1
            if size > 0 then lines = lines .. str .. "\n" end
        end,
        output_done = function ()
            callback{ size, lines }
        end
    })
end
-- }}}

return helpers.setasyncall(pkg_all)
