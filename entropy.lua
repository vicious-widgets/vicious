---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local setmetatable = setmetatable
local math = { ceil = math.ceil }
local helpers = require("vicious.helpers")
-- }}}


-- Entropy: provides available system entropy
module("vicious.entropy")


-- {{{ Entropy widget type
local function worker(format)
    local random = helpers.pathtotable("/proc/sys/kernel/random")

    -- Linux 2.6 has a default entropy pool of 4096-bits
    local poolsize = tonumber(random.poolsize)
    -- Get available entropy
    local ent = tonumber(random.entropy_avail)
    -- Calculate percentage
    local ent_percent = math.ceil(ent * 100 / poolsize)

    return {ent, ent_percent}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
