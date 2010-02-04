---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local math = { max = math.max }
local setmetatable = setmetatable
-- }}}


-- Pkg: provides number of pending updates on GNU/Linux
module("vicious.pkg")


-- {{{ Packages widget type
local function worker(format, dist)
    -- Initialise counters
    local updates = 0
    local manager = {
        ["Arch"]   = { cmd = "pacman -Qu" },
        ["Arch S"] = { cmd = "pacman -Sup", sub = 2 },
        ["Debian"] = { cmd = "apt-show-versions -u -b" },
        ["Fedora"] = { cmd = "yum list updates", sub = 3 }
    }

    -- Check if updates are available
    local pkg = manager[dist]
    local f = io.popen(pkg.cmd)

    for line in f:lines() do
        updates = updates + 1
    end
    f:close()

    return {pkg.sub and math.max(updates-pkg.sub, 0) or updates}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
