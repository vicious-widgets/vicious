---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2019, Daan V. <daan@dirkvanoverloop.be>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local math = { floor = math.floor }
local type = type
local spawn = require("vicious.spawn")
local helpers = require("vicious.helpers")
-- }}}

-- xbacklight: provides backlight level
-- vicious.widgets.xbacklight
local xbacklight_linux = {}

-- {{{ Backlight widget type
function xbacklight_linux.async(format, warg, callback)
    if not warg then warg = {} end
    if type(warg) ~= "table" then warg = { warg } end
    spawn.easy_async("xbacklight " .. table.concat(warg, " "),
        function (stdout)
            callback({ math.floor(tonumber(stdout)) })
        end)
end
--- }}

return helpers.setasyncall(xbacklight_linux)
