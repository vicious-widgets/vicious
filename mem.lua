----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
--  * Derived from Wicked, copyright of Lucas de Vries
----------------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { open = io.open }
local setmetatable = setmetatable
local math = { floor = math.floor }
-- }}}


-- Mem: provides RAM and Swap usage statistics
module("vicious.mem")


-- {{{ Memory widget type
local function worker(format)
    -- Get meminfo
    local f = io.open("/proc/meminfo")

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

    return {mem_usepercent,  mem_inuse,  mem_total,  mem_free,
            swap_usepercent, swap_inuse, swap_total, swap_free}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
