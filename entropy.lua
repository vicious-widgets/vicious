----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
----------------------------------------------------------

-- {{{ Grab environment
local io = { open = io.open }
local setmetatable = setmetatable
local math = { floor = math.floor }
local string = { format = string.format }
-- }}}


-- Entropy: provides available system entropy
module("vicious.entropy")


-- {{{ Entropy widget type
local function worker(format, poolsize)
    -- Don't waste time opening the poolsize, Linux 2.6 has a default
    -- entropy pool of 4096-bits, if needed specify otherwise
    if poolsize == nil then poolsize = 4096 end

    -- Get available entropy
    local f = io.open("/proc/sys/kernel/random/entropy_avail")
    local ent_avail = f:read("*line")
    f:close()

    -- Calculate percentage
    ent_avail_percent = math.floor(ent_avail * 100 / poolsize)
    -- This data is intended for a progressbar
    ent_avail_percent = string.format("%0d", ent_avail_percent)

    return {ent_avail, ent_avail_percent}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
