----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
--  * Derived from Maildir Biff Widget, by Fredrik Ax
----------------------------------------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local setmetatable = setmetatable
-- }}}


-- Mdir: provides a number of new and unread messages in a Maildir structure
module("vicious.mdir")


-- {{{ Maildir widget type
function worker(format, mdir)
    -- Like with the mbox count widget, we would benefit from the
    -- LuaFileSystem library. However, we didn't rely on extra
    -- libraries to this point so we won't start now. Widgets like
    -- this one are not agressive like CPU or NET, so we can keep it
    -- simple, find is OK with me if we execute every >60s
    --
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
