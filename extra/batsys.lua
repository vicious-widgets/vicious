---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc@sysphere.org>
--  * (c) 2009, Benedikt Sauer <filmor@gmail.com>
---------------------------------------------------

-- {{{ Grab environment
local lfs_available, lfs = pcall(require, "lfs")

local unpack = unpack
local setmetatable = setmetatable
local getmetatable = getmetatable
local io = { open = io.open }
local string = { format = string.format }
local math = {
    min = math.min,
    floor = math.floor
}
local os = {
    time = os.time,
    difftime = os.difftime
}
-- }}}

-- {{{ Sysfs helper
local sys_metatable = {
    __index = -- sysfs items available as lua tables
        function (table, index)
            path = table._path .. '/' .. index
            attr = lfs.attributes(path)
            if attr then
                if attr.mode == "file" then
                    return io.open(path):read("*all")
                elseif attr.mode == "directory" then
                    local obj = { _path = path }
                    setmetatable(obj, getmetatable(table))
                    return obj
                end
            end
            return nil
        end,
}

local sys = { _path = "/sys" }
setmetatable(sys, sys_metatable)
-- }}}


-- Batsys: provides state, charge, and remaining time for a requested battery using sysfs
module("vicious.batsys")


-- Initialise tables
local time_energy = {}

-- {{{ Battery widget type
local function worker(format, batid)
    local battery = sys.class.power_supply[batid]
    local battery_state = {
        ["Full\n"] = "↯",
        ["Unknown\n"] = "⌁",
        ["Charged\n"] = "↯",
        ["Charging\n"] = "+",
        ["Discharging\n"] = "-"
    }

    -- Check if the battery is present
    if not battery or battery.present == "0\n" then
        return {battery_state["Unknown\n"], 0, "N/A"}
    end


    -- Get state information
    local state = battery_state[battery.status] or battery_state["Unknown\n"]

    -- Get charge information
    if battery.energy_now then
        energy_now, energy_full = battery.energy_now, battery.energy_full
    elseif battery.charge_now then
        energy_now, energy_full = battery.charge_now, battery.charge_full
    else
        return {battery_state["Unknown\n"], 0, "N/A"}
    end

    -- Calculate percentage (but work around broken BAT/ACPI implementations)
    local charge  = energy_now / energy_full
    local percent = math.min(math.floor(charge * 100), 100)


    -- Calculate remaining (charging or discharging) time
    --
    -- Default values on our first run
    if not time_energy[batid] then
        time_energy[batid] = { os.time(), energy_now }
        return {state, percent, "N/A"}
    end

    local time, energy = unpack(time_energy[batid])
    local difft = os.difftime(os.time(), time)
    local diffe = energy_now - energy
    local rate  = diffe / difft

    if rate > 0 then
        timeleft = (energy_full - energy_now) / rate
    else
        timeleft = -energy_now / rate
    end
    local hoursleft = math.floor(timeleft / 3600)
    local minutesleft = math.floor((timeleft - hoursleft * 3600) / 60)

    return {state, percent, string.format("%02d:%02d", hoursleft, minutesleft)}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
