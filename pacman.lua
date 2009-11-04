---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
--local string = { match = string.match }
-- }}}


-- Pacman: provides number of pending updates on Arch Linux
module("vicious.pacman")


-- {{{ Pacman widget type
local function worker(format)
    -- Initialise counters
    local updates = 0

    -- Check if updates are available
    local f = io.popen("pacman -Qu")

    for line in f:lines() do
        -- Pacman 3.2 provides the number of available updates
        --updates = string.match(line, "^Targets[%s]%(([%d]+)%)") or 0
        ---- If the count changed then break out of the loop
        --if tonumber(updates) > 0 then
        --    break
        --end

        -- Pacman 3.3 returns one line per package
        updates = updates + 1
    end
    f:close()

    return {updates}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
