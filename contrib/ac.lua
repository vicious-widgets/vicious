---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
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

module("vicious.contrib.ac")

-- {{{ AC widget type
local function worker(format, warg)
    local battery = helpers.pathtotable("/sys/class/power_supply/AC")

    if battery == nil then
        return {"Off"}
    end

    if battery.online == "1\n" then
        return {"On"}
    else
        return {"Off"}
    end
end
-- }}}


setmetatable(_M, { __call = function(_, ...) return worker(...) end })
