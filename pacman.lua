----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
----------------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
-- }}}


-- Pacman: provides number of pending updates on Arch Linux
module("vicious.pacman")


-- {{{ Pacman widget type
function worker(format)
    -- Check if updates are available
    local f = io.popen("pacman -Qu")

    -- Initialise updates
    local updates = 0

    -- Get data
    for line in f:lines() do
        -- Pacman 3.3 returns one package on a line, without any extra
        -- information
        updates = updates + 1

        -- Pacman 3.2 returns 'Targets:' followed by a number of
        -- available updates and a list of packages all on one
        -- line. Since the number is provided we don't have to count
        -- them
        --updates = line:match("^Targets[%s]%(([%d]+)%)") or 0
        -- If the count changed then break out of the loop
        --if tonumber(updates) > 0 then
        --    break
        --end
    end
    f:close()

    return {updates}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
