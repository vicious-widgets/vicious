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
    local thermals = {}
    local cnt = 1
    while cnt <= #warg do
        local output = helpers.sysctl( "" .. warg[cnt] .. "" )

        if not output then
            thermals[cnt] = 0
        else
            thermals[cnt] = tonumber( string.match(output, "[%d][%d]") )
        end
        cnt = cnt + 1
    end
    return thermals
end
-- }}}

return setmetatable(thermal_freebsd, { __call = function(_, ...) return worker(...) end })
