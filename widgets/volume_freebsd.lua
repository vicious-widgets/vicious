-- {{{ Grab environment
local tonumber = tonumber
local string = { match = string.match }
local helpers = require("vicious.helpers")
local spawn = require("vicious.spawn")
-- }}}


-- Volume: provides volume levels and state of requested mixer
-- vicious.widgets.volume_freebsd
local volume_freebsd = {}


-- {{{ Volume widget type
local STATE = { on = '🔉', off = '🔈' }

local function parse(stdout, stderr, exitreason, exitcode)
    -- Capture mixer control state, e.g.       42   :  42
    local voll, volr = string.match(stdout, "([%d]+):([%d]+)\n$")
    if voll == "0" and volr == "0" then return { 0, 0, STATE.off } end
    return { tonumber(voll), tonumber(volr), STATE.on }
end

function volume_freebsd.async(format, warg, callback)
    if not warg then return callback{} end
    spawn.easy_async("mixer " .. helpers.shellquote(warg),
                     function (...) callback(parse(...)) end)
end
-- }}}

return helpers.setasyncall(volume_freebsd)
