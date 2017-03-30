---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local math = { max = math.max }
local setmetatable = setmetatable
local spawn = require("awful.spawn")
-- }}}


-- Pkg: provides number of pending updates on UNIX systems
-- vicious.widgets.pkg
local pkg_all = {}


-- {{{ Packages widget type
local function worker(format, warg)
    if not warg then return end

    -- Initialize counters
    local updates = 0
    local manager = {
        ["Arch"]   = { cmd = "pacman -Qu" },
        ["Arch C"] = { cmd = "checkupdates" },
        ["Arch S"] = { cmd = "yes | pacman -Sup", sub = 1 },
        ["Debian"] = { cmd = "apt-show-versions -u -b" },
        ["Ubuntu"] = { cmd = "aptitude search '~U'" },
        ["Fedora"] = { cmd = "yum list updates", sub = 3 },
        ["FreeBSD"] ={ cmd = "pkg version -I -l '<'" },
        ["Mandriva"]={ cmd = "urpmq --auto-select" }
    }

    -- Check if updates are available
    local _pkg = manager[warg]
    local f = io.popen(_pkg.cmd)

    local size, lines, first = 0, "", _pkg.sub or 0
    for line in f:lines() do
        if size >= first then
            lines = lines .. (size == first and "" or "\n") .. line
        end
        size = size + 1
    end
    size = math.max(size-first, 0)
    f:close()

    return {size, lines}
end
-- }}}

-- {{{ Packages widget type
function pkg_all.async(warg, callback)
    if not warg then return end

    -- Initialize counters
    local manager = {
        ["Arch"]   = { cmd = "pacman -Qu" },
        ["Arch C"] = { cmd = "checkupdates" },
        ["Arch S"] = { cmd = "yes | pacman -Sup", sub = 1 },
        ["Debian"] = { cmd = "apt-show-versions -u -b" },
        ["Ubuntu"] = { cmd = "aptitude search '~U'" },
        ["Fedora"] = { cmd = "yum list updates", sub = 3 },
        ["FreeBSD"] ={ cmd = "pkg version -I -l '<'" },
        ["Mandriva"]={ cmd = "urpmq --auto-select" }
    }

    -- Select command
    local _pkg = manager[warg]

    -- Check if updates are available
    local function parse(str)
        local size, lines, first = 0, "", _pkg.sub or 0
        for line in str:gmatch("[^\r\n]+") do
            if size >= first then
                lines = lines .. (size == first and "" or "\n") .. line
            end
            size = size + 1
        end
        size = math.max(size-first, 0)
        return {size, lines}
    end
    
    spawn.easy_async(_pkg.cmd, function(stdout) callback(parse(stdout)) end)
end
-- }}}

return setmetatable(pkg_all, { __call = function(_, ...) return worker(...) end })
