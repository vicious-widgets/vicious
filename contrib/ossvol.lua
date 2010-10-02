---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { match = string.match }
-- }}}


-- Ossvol: provides volume levels of requested OSS mixers
module("vicious.contrib.ossvol")


-- {{{ Volume widget type
local function worker(format, warg)
    if not warg then return end

    local mixer_state = {
        ["on"]  = "♫", -- "",
        ["off"] = "♩"  -- "M"
    }

    -- Get mixer control contents
    local f = io.popen("ossmix -c")
    local mixer = f:read("*all")
    f:close()

    -- Capture mixer control state
    local volu = tonumber(string.match(mixer, warg .. "[%s]([%d%.]+)"))/0.25
    local mute = string.match(mixer, "vol%.mute[%s]([%a]+)")
    -- Handle mixers without data
    if volu == nil then
       return {0, mixer_state["off"]}
    end

    -- Handle mixers without mute
    if mute == "OFF" and volu == "0"
    -- Handle mixers that are muted
    or mute == "ON" then
       mute = mixer_state["off"]
    else
       mute = mixer_state["on"]
    end

    return {volu, mute}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
