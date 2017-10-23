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
function pkg_all.async(format, warg, callback)
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

    -- Check if updates are available
    local function parse(str, skiprows)
        local size, lines, first = 0, "", skiprows or 0
        for line in str:gmatch("[^\r\n]+") do
            if size >= first then
                lines = lines .. (size == first and "" or "\n") .. line
            end
            size = size + 1
        end
        size = math.max(size-first, 0)
        return {size, lines}
    end

    -- Select command
    local _pkg = manager[warg]
    spawn.easy_async(_pkg.cmd, function(stdout) callback(parse(stdout, _pkg.sub)) end)
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
