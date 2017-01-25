-- {{{ Grab environment
local setmetatable = setmetatable
local string = { match = string.match }
local helpers = require("vicious.helpers")
-- }}}


-- Thermal: provides temperature levels of ACPI and coretemp thermal zones
-- vicious.widgets.thermal
local thermal_freebsd = {}


-- {{{ Thermal widget type
local function worker(format, warg)
    if not warg then return end
    if type(warg) ~= "table" then warg = { warg } end

    local thermals = {}

    for i=1, #warg do
        local output = helpers.sysctl(warg[i])

        if not output then
            thermals[i] = -1
        else
            thermals[i] = string.match(output, "[%d]+")
        end
    end

    return thermals
end
-- }}}

return setmetatable(thermal_freebsd, { __call = function(_, ...) return worker(...) end })
