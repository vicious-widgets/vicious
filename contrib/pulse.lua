---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, MrMagne <mr.magne@yahoo.fr>
---------------------------------------------------
-- Usage example
--
-- -- Register widget
-- vicious.register(vol, vicious.contrib.pulse, " $1%", 2, "alsa_output.pci-0000_00_1b.0.analog-stereo")
-- -- Register buttons
-- vol:buttons(awful.util.table.join(
--   awful.button({ }, 1, function () awful.util.spawn("pavucontrol") end),
--   awful.button({ }, 4, function () vicious.contrib.pulse.add(5,"alsa_output.pci-0000_00_1b.0.analog-stereo") end),
--   awful.button({ }, 5, function () vicious.contrib.pulse.add(-5,"alsa_output.pci-0000_00_1b.0.analog-stereo") end)
-- ))
---------------------------------------------------

-- {{{ Grab environment
local type = type
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
local os = { execute = os.execute }
local table = { insert = table.insert }
local string = {
    find = string.find,
    match = string.match,
    format = string.format,
    gmatch = string.gmatch
}
-- }}}


-- Pulse: provides volume levels of requested pulseaudio sinks
module("vicious.contrib.pulse")


-- {{{ Helper function
local function get_sink_name(sink)
    -- If no sink is specified take the first one
    if sink == nil then
        local f = io.popen("pacmd list-sinks | grep name:")
        local line = f:read("*all")
        f:close()

        sink = string.match(line, "<(.*)>")
    -- If sink is an index, retrieve its name
    elseif type(sink) == "number" then
        local f = io.popen("pacmd list-sinks | grep name:")
        local line = f:read("*all")
        f:close()

        local sinks = {}
        for s in string.gmatch(line, "<(.*)>") do
            table.insert(sinks, s)
        end

        sink = sinks[sink]
    end

    return sink
end
-- }}}

-- {{{ Pulseaudio widget type
local function worker(format, sink)
    sink = get_sink_name(sink)
    if sink == nil then return {0} end

    -- Get sink data
    local f = io.popen("pacmd dump | grep '\\(set-sink-volume " .. sink.."\\)\\|\\(set-sink-mute "..sink.."\\)'")
    local data = f:read("*all")
    f:close()

    -- If mute return 0 (not "Mute") so we don't break progressbars
    if string.match(data," (yes)\n$") then
        return {0}
    end

    local vol = tonumber(string.match(data, "(0x[%x]+)"))
    if vol == nil then vol = 0 end

    return { vol/0x10000*100 }
end
-- }}}

-- {{{ Volume control helper
function add(percent, sink)
    sink = get_sink_name(sink)
    if sink == nil then return end

    local f = io.popen("pacmd dump | grep 'set-sink-volume " .. sink.."'")
    local data = f:read("*all")
    f:close()

    local initial_vol =  tonumber(string.match(data, "(0x[%x]+)"))
    local vol = initial_vol + percent/100*0x10000
    if vol > 0x10000 then vol = 0x10000 end
    if vol < 0 then vol = 0 end

    local cmd = "pacmd set-sink-volume "..sink..string.format(" 0x%x", vol).." >/dev/null"
    os.execute(cmd)
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
