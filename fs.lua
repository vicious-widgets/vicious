----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
----------------------------------------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local setmetatable = setmetatable
-- }}}


-- FS: provides file system disk space usage
module("vicious.fs")


-- {{{ Filesystem widget type
local function worker(format)
    -- Get data from df
    local f = io.popen("LANG=C df -hP")
    local fs_info = {}

    -- Format data
    for line in f:lines() do
        if not line:match("^Filesystem.*") then
            -- Format helper can't deal with matrices, so don't setup a
            -- table for each mount point with gmatch
            local size, used, avail, usep, mount =
             -- Instead match all at once, including network file systems
             line:match('^[/%w:%.-]+[%s]+([%d%.]+)[%a]?[%s]+([%d%.]+)[%a]?[%s]+([%d%.]+)[%a]?[%s]+([%d]+)%%[%s]+([/%w:%.-]+)$')

            fs_info["{"..mount.." size}"]  = size
            fs_info["{"..mount.." used}"]  = used
            fs_info["{"..mount.." avail}"] = avail
            fs_info["{"..mount.." usep}"]  = usep
        end
    end
    f:close()

    return fs_info
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
