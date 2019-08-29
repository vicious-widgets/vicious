-- {{{ Grab environment
local tonumber = tonumber
local math = { floor = math.floor }
local os = { time = os.time }

local helpers = require("vicious.helpers")
-- }}}


-- Uptime: provides system uptime and load information
-- vicious.widgets.uptime
local uptime_freebsd = {}


-- {{{ Uptime widget type
function uptime_freebsd.async(format, warg, callback)
    helpers.sysctl_async(
        { "vm.loadavg", "kern.boottime" },
        function(ret)
            local l1, l5, l15 = ret["vm.loadavg"]:match(
                "{ ([%d]+%.[%d]+) ([%d]+%.[%d]+) ([%d]+%.[%d]+) }")
            local up_t = os.time() - tonumber(
                ret["kern.boottime"]:match"sec = ([%d]+)")

            -- Get system uptime
            local up_d = math.floor(up_t   / (3600 * 24))
            local up_h = math.floor((up_t  % (3600 * 24)) / 3600)
            local up_m = math.floor(((up_t % (3600 * 24)) % 3600) / 60)

            return callback({ up_d, up_h, up_m, l1, l5, l15 })
        end)
end
-- }}}

return helpers.setasyncall(uptime_freebsd)
