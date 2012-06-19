---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
--  * (c) 2009, Lucas de Vries <lucas@glacicle.com>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { match = string.match }
local helpers = require("vicious.helpers")
-- }}}


-- FS: provides file system disk space usage
-- vicious.widgets.fs
local fs = {}


-- Variable definitions
local unit = { ["mb"] = 1024, ["gb"] = 1024^2 }

-- {{{ Filesystem widget type
local function worker(format, warg)
    -- Fallback to listing local filesystems
    if warg then warg = "" else warg = "-l" end

    local fs_info = {} -- Get data from df
    local f = io.popen("LC_ALL=C df -kP " .. warg)

    for line in f:lines() do -- Match: (size) (used)(avail)(use%) (mount)
        local s     = string.match(line, "^.-[%s]([%d]+)")
        local u,a,p = string.match(line, "([%d]+)[%D]+([%d]+)[%D]+([%d]+)%%")
        local m     = string.match(line, "%%[%s]([%p%w]+)")

        if u and m then -- Handle 1st line and broken regexp
            helpers.uformat(fs_info, m .. " size",  s, unit)
            helpers.uformat(fs_info, m .. " used",  u, unit)
            helpers.uformat(fs_info, m .. " avail", a, unit)

            fs_info["{" .. m .. " used_p}"]  = tonumber(p)
            fs_info["{" .. m .. " avail_p}"] = 100 - tonumber(p)
        end
    end
    f:close()

    return fs_info
end
-- }}}

return setmetatable(fs, { __call = function(_, ...) return worker(...) end })
