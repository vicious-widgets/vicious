---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Radu A. <admiral0@tuxfamily.org>
---------------------------------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local setmetatable = setmetatable
local table = { insert = table.insert }
-- }}}


-- Netcfg: provides active netcfg network profiles
-- vicious.contrib.netcfg
local netcfg = {}


-- {{{ Netcfg widget type
local function worker(format)
    -- Initialize counters
    local profiles = {}

    local f = io.popen("ls -1 /var/run/network/profiles")
    for line in f:lines() do
        if line ~= nil then
            table.insert(profiles, line)
        end
    end
    f:close()

    return profiles
end
-- }}}

return setmetatable(netcfg, { __call = function(_, ...) return worker(...) end })
