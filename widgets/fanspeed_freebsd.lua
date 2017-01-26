-- {{{ Grab environment
local setmetatable = setmetatable
local helpers = require("vicious.helpers")
local tonumber = tonumber
-- }}}


-- fanspeed: provides speed level of main fan
--
-- expects one (1) full sysctl string to entry
--   e.g.: "dev.acpi_ibm.0.fan_speed"

local fanspeed_freebsd = {}

local function worker(format, warg)
    if not warg then return end

    local fanspeed = helpers.sysctl(warg)

    if not fanspeed then
        -- use negative fanspeed to indicate error
        return {-1}
    else
        return {tonumber(fanspeed)}
    end
end

return setmetatable(fanspeed_freebsd, { __call = function(_, ...) return worker(...) end })
