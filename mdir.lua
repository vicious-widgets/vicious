---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc.sysphere.org>
--  * (c) Maildir Biff Widget, Fredrik Ax
---------------------------------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local setmetatable = setmetatable
-- }}}


-- Mdir: provides a number of new and unread messages in a Maildir structure
module("vicious.mdir")


-- {{{ Maildir widget type
local function worker(format, mdir)
    -- Initialise counters
    local newcount = 0
    local curcount = 0

    -- Recursively find new messages
    local fnew = io.popen("find " .. mdir .. " -type f -wholename '*/new/*'")
    for line in fnew:lines() do
        newcount = newcount + 1
    end
    fnew:close()

    -- Recursively find "old" messages lacking the Seen flag
    local fcur = io.popen("find " .. mdir .. " -type f -regex '.*/cur/.*2,[^S]*$'")
    for line in fcur:lines() do
        curcount = curcount + 1
    end
    fcur:close()

    return {newcount, curcount}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
