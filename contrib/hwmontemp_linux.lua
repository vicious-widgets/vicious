----------------------------------------------------------------
--   Licensed under the GNU General Public License v2
--   (C) 2019, Alexander Koch <lynix47@gmail.com>
----------------------------------------------------------------

-- environment
local io = { popen = io.popen, open = io.open }
local setmetatable = setmetatable

-- sysfs prefix for hwmon devices
local sys_hwmon = "/sys/class/hwmon"
-- cache table for hwmon device names
local paths = {}

-- transparently caching hwmon device name lookup
function name_to_path(name)
    if paths[name] then return paths[name] end

    for sensor in io.popen("ls -1 " .. sys_hwmon):lines() do
        local path = sys_hwmon .. "/" .. sensor
        local f = assert(io.open(path .. "/name", "r"))
        local sname = f:read("*line")
        f:close()
        if sname == name then
            paths[name] = path
            return path
        end
    end

    return nil
end

-- hwmontemp: provides name-indexed temps from /sys/class/hwmon
-- vicious.contrib.hwmontemp
local hwmontemp_linux = {}

function worker(format, warg)
    if not warg[1] then
        return { "E" }
    end
    name = warg[1]

    if not warg[2] then
        input = 1
    else
        input = warg[2]
    end

    local sensor = name_to_path(name)
    if not sensor then return { "n/a" } end

    local f = assert(io.open(sensor .. "/temp" .. input .. "_input", "r"))
    local temp = f:read("*line")
    f:close()

    return { temp / 1000 }
end

return setmetatable(hwmontemp_linux, { __call = function(_, ...) return worker(...) end })

-- vim: ts=4:sw=4:expandtab
