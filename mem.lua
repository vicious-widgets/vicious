----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
----------------------------------------------------------

-- {{{ Grab environment
local type = type
local tonumber = tonumber
local io = { open = io.open }
local math = { floor = math.floor }
local helpers = require("vicious.helpers")
-- }}}


-- Mem: provides RAM and Swap usage statistics
module("vicious.mem")


-- {{{ Memory widget type
function worker(format, padding)
    -- Get meminfo
    local f = io.open("/proc/meminfo")

    -- Get data
    for line in f:lines() do
        if line:match("^MemTotal.*") then
            mem_total = math.floor(tonumber(line:match("([%d]+)")) / 1024)
        elseif line:match("^MemFree.*") then
            free = math.floor(tonumber(line:match("([%d]+)")) / 1024)
        elseif line:match("^Buffers.*") then
            buffers = math.floor(tonumber(line:match("([%d]+)")) / 1024)
        elseif line:match("^Cached.*") then
            cached = math.floor(tonumber(line:match("([%d]+)")) / 1024)
        -- Get swap stats while we're at it
        elseif line:match("^SwapTotal.*") then
            swap_total = math.floor(tonumber(line:match("([%d]+)")) / 1024)
        elseif line:match("^SwapFree.*") then
            swap_free = math.floor(tonumber(line:match("([%d]+)")) / 1024)
        end
    end
    f:close()

    -- Calculate percentage
    mem_free = free + buffers + cached
    mem_inuse = mem_total - mem_free
    mem_usepercent = math.floor(mem_inuse/mem_total*100)
    -- Calculate swap percentage
    swap_inuse = swap_total - swap_free
    swap_usepercent = math.floor(swap_inuse/swap_total*100)

    if padding then
        if type(padding) == "table" then
            mem_usepercent = helpers.padd(mem_usepercent, padding[1])
            mem_inuse = helpers.padd(mem_inuse, padding[2])
            mem_total = helpers.padd(mem_total, padding[3])
            mem_free  = helpers.padd(mem_free,  padding[4])
            swap_usepercent = helpers.padd(swap_usepercent, padding[1])
            swap_inuse = helpers.padd(swap_inuse, padding[2])
            swap_total = helpers.padd(swap_total, padding[3])
            swap_free = helpers.padd(swap_free, padding[4])
        else
            mem_usepercent = helpers.padd(mem_usepercent, padding)
            mem_inuse = helpers.padd(mem_inuse, padding)
            mem_total = helpers.padd(mem_total, padding)
            mem_free  = helpers.padd(mem_free,  padding)
            swap_usepercent = helpers.padd(swap_usepercent, padding)
            swap_inuse = helpers.padd(swap_inuse, padding)
            swap_total = helpers.padd(swap_total, padding)
            swap_free = helpers.padd(swap_free, padding)
        end
    end

    return {mem_usepercent,  mem_inuse,  mem_total,  mem_free,
            swap_usepercent, swap_inuse, swap_total, swap_free}
end
-- }}}
