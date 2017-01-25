-- {{{ Grab environment
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { match = string.match }
local helpers = require("vicious.helpers")
-- }}}


-- Volume: provides volume levels and state of requested mixer
-- vicious.widgets.volume_freebsd
local volume_freebsd = {}


-- {{{ Volume widget type
local function worker(format, warg)
    if not warg then return end

    local mixer_state = { "♫", "♩" }

    -- Get mixer control contents
    f = io.popen("mixer -s " .. helpers.shellquote(warg))
    local mixer = f:read()
    f:close()

    -- Capture mixer control state:          [5%] ... ... [on]
    local voll, volr = string.match(mixer, "([%d]+):([%d]+)$")

    if voll == "0" and volr == "0" then
        return {0, 0, mixer_state[2]}
    else
        return {voll, volr, mixer_state[1]}
    end

end
-- }}}

return setmetatable(volume_freebsd, { __call = function(_, ...) return worker(...) end })
