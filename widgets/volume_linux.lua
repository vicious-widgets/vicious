---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local setmetatable = setmetatable
local string = { match = string.match }
local table  = { concat = table.concat }

local helpers = require("vicious.helpers")
local spawn = require("vicious.spawn")
-- }}}


-- Volume: provides volume levels and state of requested ALSA mixers
-- vicious.widgets.volume
local volume_linux = {}

-- {{{ Volume widget type
local STATE = { on = '🔉', off = '🔈' }

local function parse(stdout, stderr, exitreason, exitcode)
    -- Capture mixer control state, e.g.        [  42    % ]   [  on    ]
    local volume, state = string.match(stdout, "%[([%d]+)%%%].*%[([%l]*)%]")
    -- Handle mixers without data
    if volume == nil then return { 0, STATE.off } end

    if state == "" and volume == "0"    -- handle mixers without mute
       or state == "off" then           -- handle muted mixers
        return { tonumber(volume), STATE.off }
    else
        return { tonumber(volume), STATE.on }
    end
end

function volume_linux.async(format, warg, callback)
    if not warg then return callback{} end
    if type(warg) ~= "table" then warg = { warg } end
    spawn.easy_async("amixer -M get " .. table.concat(warg, " "),
                     function (...) callback(parse(...)) end)
end

local function worker(format, warg)
    local ret
    volume_linux.async(format, warg, function (volume) ret = volume end)
    while ret == nil do end
    return ret
end
-- }}}

return setmetatable(volume_linux, { __call = function(_, ...) return worker(...) end })
