---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
-- }}}


-- Pkg: provides number of pending updates on GNU/Linux
module("vicious.pkg")


-- {{{ Packages widget type
local function worker(format)
    -- Initialise counters
    local updates = 0

    -- Check if updates are available on Arch
    local f = io.popen("pacman -Qu")
    --- Exclude IgnorePkg and count deps
    ---local f = io.popen("pacman -Sup")

    for line in f:lines() do
        updates = updates + 1
    end
    f:close()

    return {updates}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
