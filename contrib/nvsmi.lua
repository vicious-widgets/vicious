---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2014, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { match = string.match }
-- }}}


-- nvsmi: provides GPU information from nvidia SMI
-- vicious.contrib.nvsmi
local nvsmi = {}


-- {{{ GPU Information widget type
local function worker(format, warg)
    -- Fallback to querying first device
    if not warg then warg = "0" end

    -- Get data from smi
    -- * Todo: support more; MEMORY,UTILIZATION,ECC,POWER,CLOCK,COMPUTE,PIDS,PERFORMANCE
    local f = io.popen("nvidia-smi -q -d TEMPERATURE -i " .. warg)
    local smi = f:read("*all")
    f:close()

    -- Not installed
    if smi == nil then return {0} end

    -- Get temperature information
    local _thermal = string.match(smi, "Gpu[%s]+:[%s]([%d]+)[%s]C")
    -- Handle devices without data
    if _thermal == nil then return {0} end

    return {tonumber(_thermal)}
end
-- }}}

return setmetatable(nvsmi, { __call = function(_, ...) return worker(...) end })
