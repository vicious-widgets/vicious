----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
----------------------------------------------------------

-- {{{ Grab environment
local type = type
local io = { popen = io.popen }
local setmetatable = setmetatable
local helpers = require("vicious.helpers")
-- }}}


-- FS: provides usage statistics for requested mount points
module("vicious.fs")


-- {{{ Filesystem widget type
function worker(format, padding)
    -- Get data from df
    local f = io.popen("df -hP")
    local args = {}

    -- Format data
    for line in f:lines() do
        if not line:match("^Filesystem.*") then
            -- Format helper can't deal with matrices, so don't setup a
            -- table for each mount point with gmatch
            local size, used, avail, usep, mount =
             -- Instead match all at once, including network file systems
             line:match("^[%w/-:%.]+[%s]+([%d%.]+)[%a]?[%s]+([%d%.]+)[%a]?[%s]+([%d%.]+)[%a]?[%s]+([%d]+)%%[%s]+([-/%w]+)$")

            if padding then
                if type(padding) == "table" then
                    size  = helpers.padd(size,  padding[1])
                    used  = helpers.padd(used,  padding[2])
                    avail = helpers.padd(avail, padding[3])
                    usep  = helpers.padd(usep,  padding[4])
                else
                    size  = helpers.padd(size,  padding)
                    used  = helpers.padd(used,  padding)
                    avail = helpers.padd(avail, padding)
                    usep  = helpers.padd(usep,  padding)
                end
            end

            args["{"..mount.." size}"]  = size
            args["{"..mount.." used}"]  = used
            args["{"..mount.." avail}"] = avail
            args["{"..mount.." usep}"]  = usep
        end
    end
    f:close()

    return args
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
