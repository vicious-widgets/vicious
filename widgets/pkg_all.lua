---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local setmetatable = setmetatable
local spawn = require("vicious.spawn")
-- }}}


-- Pkg: provides number of pending updates on UNIX systems
-- vicious.widgets.pkg
local pkg_all = {}

local PKGMGR = {
    ["Arch"] = { cmd = "pacman -Qu" },
    ["Arch C"] = { cmd = "checkupdates" },
    ["Arch S"] = { cmd = "yes | pacman -Sup", sub = 1 },
    ["Debian"] = { cmd = "apt list --upgradable", sub = 1 },
    ["Ubuntu"] = { cmd = "apt list --upgradable", sub = 1 },
    ["Fedora"] = { cmd = "dnf check-update", sub = 2 },
    ["FreeBSD"] = { cmd = "pkg version -I -l '<'" },
    ["Mandriva"] = { cmd = "urpmq --auto-select" }
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

-- {{{ Packages widget type
local function worker(format, warg)
    local ret = nil

    pkg_all.async(format, warg, function(data) ret = data end)

    while ret==nil do end
    return ret
end
-- }}}


return setmetatable(pkg_all, { __call = function(_, ...) return worker(...) end })
