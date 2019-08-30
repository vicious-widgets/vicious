-- {{{ Grab environment
local tonumber = tonumber
local type = type

local helpers = require("vicious.helpers")
-- }}}


-- fanspeed: provides speed level of fans
-- vicious.widgets.fanspeed
--
-- expects one or multiple full sysctl strings to entry
--   e.g.: "dev.acpi_ibm.0.fan_speed"
local fanspeed_freebsd = {}

-- {{{ fanspeed widget type
function fanspeed_freebsd.async(format, warg, callback)
    if not warg then return callback({}) end
    if type(warg) ~= "table" then warg = { warg } end

    helpers.sysctl_async(warg, function(ret)
        local fanspeed = {}

        for i=1,#warg do
            if ret[warg[i]] ~= nil then
                fanspeed[i] = tonumber(ret[warg[i]])
            else
                fanspeed[i] = "N/A"
            end
        end

        callback(fanspeed)
    end)
end
-- }}}

return helpers.setasyncall(fanspeed_freebsd)
