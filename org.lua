---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc@sysphere.org>
--  * (c) org-awesome, Damien Leone
---------------------------------------------------

-- {{{ Grab environment
local io = { open = io.open }
local setmetatable = setmetatable
local string = { find = string.find }
local os = {
    time = os.time,
    date = os.date
}
-- }}}


-- Org: provides agenda statistics for Emacs org-mode
module("vicious.org")


-- {{{ OrgMode widget type
local function worker(format, warg)
    -- Compute delays
    local today  = os.time{ year=os.date("%Y"), month=os.date("%m"), day=os.date("%d") }
    local soon   = today + 24 * 3600 * 3 -- 3 days ahead is close
    local future = today + 24 * 3600 * 7 -- 7 days ahead is maximum

    -- Initialise counters
    local count = { past = 0, today = 0, soon = 0, future = 0 }

    -- Get data from agenda files
    for i=1, #warg do
       local f = io.open(warg[i])

       for line in f:lines() do
          local scheduled = string.find(line, "SCHEDULED:")
          local closed    = string.find(line, "CLOSED:")
          local deadline  = string.find(line, "DEADLINE:")

          if (scheduled and not closed) or (deadline and not closed) then
             local b, e, y, m, d = string.find(line, "(%d%d%d%d)-(%d%d)-(%d%d)")

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

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
