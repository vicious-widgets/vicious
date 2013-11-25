---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2013, NormalRa <normalrawr gmail com>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { open = io.open }
local setmetatable = setmetatable
local helpers = require("vicious.helpers")
local string = {
    sub = string.sub,
    match = string.match,
    gmatch = string.gmatch
}
-- }}}


-- ATI: provides various info about ATI GPU status
-- vicious.widgets.ati
local ati = {}


-- {{{ Define variables
local _units = { clock = { ["khz"] = 1, ["mhz"] = 1000 },
                voltage = { ["v"] = 1, ["mv"]  = 1000 } }
local _reps = {
    ["sclk"]    = { name = "engine_clock", units = _units.clock, mul = 10 },
    ["mclk"]    = { name = "memory_clock", units = _units.clock, mul = 10 },
    ["vddc"]    = { name = "voltage", units = _units.voltage },
    ["voltage"] = { name = "voltage", units = _units.voltage },
    ["current engine clock"] = { name = "engine_clock", units = _units.clock },
    ["current memory clock"] = { name = "memory_clock", units = _units.clock }
}
-- }}}

-- {{{ ATI widget type
local function worker(format, warg)
    if not warg then return end

    local pm = helpers.pathtotable("/sys/class/drm/"..warg.."/device")
    local _data = {}

    -- Get power info
    _data["{method}"] =
        pm.power_method     and string.sub(pm.power_method,     1, -2) or "N/A"
    _data["{dpm_state}"] =
        pm.power_dpm_state  and string.sub(pm.power_dpm_state,  1, -2) or "N/A"
    _data["{dpm_perf_level}"] =
        pm.power_dpm_force_performance_level and
        string.sub(pm.power_dpm_force_performance_level,        1, -2) or "N/A"
    _data["{profile}"] =
        pm.power_profile    and string.sub(pm.power_profile,    1, -2) or "N/A"

    local f = io.open("/sys/kernel/debug/dri/64/radeon_pm_info", "r")
    if f then -- Get ATI info from the debug filesystem
        for line in f:lines() do
            for k, unit in string.gmatch(line, "(%a+[%a%s]*):[%s]+([%d]+)") do
                unit = tonumber(unit)

                _data["{dpm_power_level}"] = -- DPM active?
                        tonumber(string.match(line, "power level ([%d])")) or "N/A"

                if _reps[k] then
                    for u, v in pairs(_reps[k].units) do
                        _data["{".._reps[k].name.." "..u.."}"] =
                             (unit * (_reps[k].mul or 1)) / v
                    end
                end
            end
        end
        f:close()
    end

    return _data
end
-- }}}

return setmetatable(ati, { __call = function(_, ...) return worker(...) end })
