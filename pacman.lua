----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
----------------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { popen = io.popen }
-- }}}


-- Pacman: provides number of pending updates on Arch Linux
module("vicious.pacman")


-- {{{ Pacman widget type
function worker(format)
    -- Check if updates are available
    local f = io.popen("pacman -Qu")

    -- Initialise updates
    local updates = nil

    -- Get data
    for line in f:lines() do
        -- If there are 'Targets:' then updates are available,
        -- number is provided, we don't have to count packages
        updates = line:match("^Targets[%s]%(([%d]+)%)") or 0
        -- If the count changed then break out of the loop
        if tonumber(updates) > 0 then
            break
        end
    end
    f:close()

    return {updates}
end
-- }}}
