---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
--  * (c) Maildir Biff Widget, Fredrik Ax
---------------------------------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local setmetatable = setmetatable
-- }}}


-- Mdir: provides the number of new and unread messages in Maildir structures/dirs
module("vicious.widgets.mdir")


-- {{{ Maildir widget type
local function worker(format, warg)
    if not warg then return end

    -- Initialize counters
    local count = { new = 0, cur = 0 }

    for i=1, #warg do
        -- Recursively find new messages
        local f = io.popen("find "..warg[i].." -type f -wholename '*/new/*'")
        for line in f:lines() do count.new = count.new + 1 end
        f:close()

        -- Recursively find "old" messages lacking the Seen flag
        local f = io.popen("find "..warg[i].." -type f -regex '.*/cur/.*2,[^S]*$'")
        for line in f:lines() do count.cur = count.cur + 1 end
        f:close()
    end

    return {count.new, count.cur}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
