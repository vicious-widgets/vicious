---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc.sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local io = { open = io.open }
local setmetatable = setmetatable
local math = { ceil = math.ceil }
-- }}}


-- Entropy: provides available system entropy
module("vicious.entropy")


-- {{{ Entropy widget type
local function worker(format, poolsize)
    -- Linux 2.6 has a default entropy pool of 4096-bits
    if poolsize == nil then poolsize = 4096 end

    -- Get available entropy
    local f = io.open("/proc/sys/kernel/random/entropy_avail")
    local ent_avail = f:read("*line")
    f:close()

    -- Calculate percentage
    local ent_avail_percent = math.ceil(ent_avail * 100 / poolsize)

    return {ent_avail, ent_avail_percent}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
