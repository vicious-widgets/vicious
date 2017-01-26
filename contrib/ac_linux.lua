---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2012, jinleileiking <jinleileiking@gmail.com>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local setmetatable = setmetatable
local string = { format = string.format }
local helpers = require("vicious.helpers")
local math = {
    min = math.min,
    floor = math.floor
}
-- }}}

local ac_linux = {}

-- {{{ AC widget type
local function worker(format, warg)
    local ac = helpers.pathtotable("/sys/class/power_supply/"..warg)

    local state = ac.online
    if state == nil then
        return {"N/A"}
    elseif state == "1\n" then
        return {"On"}
    else
        return {"Off"}
    end
end
-- }}}


return setmetatable(ac_linux, { __call = function(_, ...) return worker(...) end })
