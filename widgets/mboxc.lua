---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local io = { open = io.open }
local setmetatable = setmetatable
local string = { find = string.find }
-- }}}


-- Mboxc: provides the count of total, old and new messages in mbox files
-- vicious.widgets.mboxc
local mboxc = {}


-- {{{ Mbox count widget type
local function worker(format, warg)
    if not warg then return end

    -- Initialize counters
    local count = { old = 0, total = 0, new = 0 }

    -- Get data from mbox files
    for i=1, #warg do
        local f = io.open(warg[i])

        while true do
            -- Read the mbox line by line, if we are going to read
            -- some *HUGE* folders then switch to reading chunks
            local lines = f:read("*line")
            if not lines then break end

            -- Find all messages
            --  * http://www.jwz.org/doc/content-length.html
            local _, from = string.find(lines, "^From[%s]")
            if from ~= nil then count.total = count.total + 1 end

            -- Read messages have the Status header
            local _, status = string.find(lines, "^Status:[%s]RO$")
            if status ~= nil then count.old = count.old + 1 end

            -- Skip the folder internal data
            local _, int = string.find(lines, "^Subject:[%s].*FOLDER[%s]INTERNAL[%s]DATA")
            if int ~= nil then count.total = count.total - 1 end
        end
        f:close()
    end

    -- Substract total from old to get the new count
    count.new = count.total - count.old

    return {count.total, count.old, count.new}
end
-- }}}

return setmetatable(mboxc, { __call = function(_, ...) return worker(...) end })
