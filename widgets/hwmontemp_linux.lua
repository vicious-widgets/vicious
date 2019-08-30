----------------------------------------------------------------
--   Licensed under the GNU General Public License v2
--   (C) 2019, Alexander Koch <lynix47@gmail.com>
----------------------------------------------------------------

-- environment
local type = type
local tonumber = tonumber
local io = { open = io.open }

local helpers = require"vicious.helpers"
local spawn = require"vicious.spawn"

-- hwmontemp: provides name-indexed temps from /sys/class/hwmon
-- vicious.widgets.hwmontemp
return helpers.setasyncall{
    async = function (format, warg, callback)
        if type(warg) ~= "table" or type(warg[1]) ~= "string" then
            return callback{}
        end
        local input = warg[2]
        if type(input) == "number" then
            input = ("temp%d_input"):format(input)
        else
            input = "temp1_input"
        end

        spawn.easy_async_with_shell(
            "grep " .. warg[1] .. " -wl /sys/class/hwmon/*/name",
            function (stdout, stderr, exitreason, exitcode)
                if exitreason == "exit" and exitcode == 0 then
                    local f = io.open(stdout:gsub("name%s+", input), "r")
                    callback{ tonumber(f:read"*line") / 1000 }
                    f:close()
                else
                    callback{}
                end
            end)
    end }
-- vim: ts=4:sw=4:expandtab
