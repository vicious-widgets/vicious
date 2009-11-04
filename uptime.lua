---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc@sysphere.org>
--  * (c) 2008, Lucas de Vries <lucas@glacicle.com>
---------------------------------------------------

-- {{{ Grab environment
local io = { open = io.open }
local setmetatable = setmetatable
local math = { floor = math.floor }
local string = { match = string.match }
-- }}}


-- Uptime: provides system uptime information
module("vicious.uptime")


-- {{{ Uptime widget type
local function worker(format)
    -- Get /proc/uptime
    local f = io.open("/proc/uptime")
    local line = f:read("*line")
    f:close()

    local up_t = math.floor(string.match(line, "[%d]+"))
    local up_d = math.floor(up_t   / (3600 * 24))
    local up_h = math.floor((up_t  % (3600 * 24)) / 3600)
    local up_m = math.floor(((up_t % (3600 * 24)) % 3600) / 60)
    local up_s = math.floor(((up_t % (3600 * 24)) % 3600) % 60)

    return {up_t, up_d, up_h, up_m, up_s}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
