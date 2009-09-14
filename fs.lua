----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
--  * Contributor Joerg Jaspert <joerg_debian_org>
----------------------------------------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local setmetatable = setmetatable
-- }}}


-- FS: provides file system disk space usage
module("vicious.fs")


-- {{{ Filesystem widget type
local function worker(format, nfs)
    -- Fallback to listing only local file systems
    if nfs then nfs = "" else nfs = "--local" end

    -- Get data from df
    local f = io.popen("LANG=C df -hP " .. nfs)
    local fs_info = {}

    for line in f:lines() do
        if not line:match("^Filesystem.*") then
            local size, used, avail, usep, mount =
             -- Match all at once, including network file systems
             line:match("^[%w%p]+[%s]+([%d%.]+)[%a]?[%s]+([%d%.]+)[%a]?[%s]+([%d%.]+)[%a]?[%s]+([%d]+)%%[%s]+([%w%p]+)$")

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
