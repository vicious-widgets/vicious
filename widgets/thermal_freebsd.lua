-- {{{ Grab environment
local string = { match = string.match }
local type = type

local helpers = require("vicious.helpers")
-- }}}


-- Thermal: provides temperature levels of ACPI and coretemp thermal zones
-- vicious.widgets.thermal
local thermal_freebsd = {}

-- {{{ Thermal widget type
function thermal_freebsd.async(format, warg, callback)
    if not warg then return callback{} end
    if type(warg) ~= "table" then warg = { warg } end

    helpers.sysctl_async(warg, function(ret)
        local thermals = {}

        for i=1,#warg do
            if ret[warg[i]] ~= nil then
                thermals[i] = string.match(ret[warg[i]], "[%d]+")
            else
                thermals[i] = "N/A"
            end
        end

        callback(thermals)
    end)
end
-- }}}

return helpers.setasyncall(thermal_freebsd)
