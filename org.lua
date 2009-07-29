----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
--  * Derived from org-awesome, copyright of Damien Leone
----------------------------------------------------------

-- {{{ Grab environment
local io = { open = io.open }
local string = { find = string.find }
local os = {
    time = os.time,
    date = os.date
}
-- }}}


-- Org: provides agenda statistics for Emacs org-mode
module("vicious.org")


-- {{{ OrgMode widget type
function worker(format, files)
    -- Compute delays
    local today  = os.time{ year=os.date("%Y"), month=os.date("%m"), day=os.date("%d") }
    local soon   = today + 24 * 3600 * 3 -- 3 days ahead is close
    local future = today + 24 * 3600 * 7 -- 7 days ahead is maximum

    -- Initialise count table
    local count  = {
        past   = 0,
        today  = 0,
        soon   = 0,
        future = 0
    }

    -- Get data from agenda files
    for i=1, #files do
       local f = io.open(files[i])

       -- Parse the agenda
       for line in f:lines() do
          local scheduled = string.find(line, "SCHEDULED:")
          local closed    = string.find(line, "CLOSED:")
          local deadline  = string.find(line, "DEADLINE:")

          if (scheduled and not closed) or (deadline and not closed) then
             local b, e, y, m, d = string.find(line, "(%d%d%d%d)-(%d%d)-(%d%d)")

             -- Enumerate agenda items
             if b then
                local t = os.time{ year = y, month = m, day = d }

                if t < today then
                    count.past = count.past + 1
                elseif t == today then
                    count.today = count.today + 1
                elseif t <= soon then
                    count.soon = count.soon + 1
                elseif t <= future then
                    count.future = count.future + 1
                end
             end
          end
       end
       f:close()
    end

    return {count.past, count.today, count.soon, count.future}
end
-- }}}
