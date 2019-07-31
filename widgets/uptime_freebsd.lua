-- {{{ Grab environment
local tonumber = tonumber
local setmetatable = setmetatable
local math = { floor = math.floor }
local string = { match = string.match }
local helpers = require("vicious.helpers")
local os = { time = os.time }
-- }}}


-- Uptime: provides system uptime and load information
-- vicious.widgets.uptime
local uptime_freebsd = {}


-- {{{ Uptime widget type
function uptime_freebsd.async(format, warg, callback)
    helpers.sysctl_async({ "vm.loadavg", 
                           "kern.boottime" }, 
                         function(ret)
        local l1, l5, l15 = string.match(ret["vm.loadavg"], "{ ([%d]+%.[%d]+) ([%d]+%.[%d]+) ([%d]+%.[%d]+) }")
        local up_t = os.time() - tonumber(string.match(ret["kern.boottime"], "sec = ([%d]+)"))

        -- Get system uptime
        local up_d = math.floor(up_t   / (3600 * 24))
        local up_h = math.floor((up_t  % (3600 * 24)) / 3600)
        local up_m = math.floor(((up_t % (3600 * 24)) % 3600) / 60)

        return callback({ up_d, up_h, up_m, l1, l5, l15 })
    end)
end
-- }}}

return helpers.setasyncall(uptime_freebsd)
