---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc@sysphere.org>
--  * (c) 2008, Lucas de Vries <lucas@glacicle.com>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { match = string.match }
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
        if not string.match(line, "^Filesystem.*") then
            local size, used, avail, usep, mount = string.match(line, --  Match all (network file systems too)
             "^[%w%p]+[%s]+([%d%.]+)[%a]?[%s]+([%d%.]+)[%a]?[%s]+([%d%.]+)[%a]?[%s]+([%d]+)%%[%s]+([%w%p]+)$")

            fs_info["{"..mount.." size}"]  = tonumber(size)
            fs_info["{"..mount.." used}"]  = tonumber(used)
            fs_info["{"..mount.." avail}"] = tonumber(avail)
            fs_info["{"..mount.." usep}"]  = tonumber(usep)
        end
    end
    f:close()

    return fs_info
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
