---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = {
    find = string.find,
    match = string.match
}
-- }}}


-- Ossvol: provides volume levels of requested OSS mixers
module("vicious.widgets.ossvol")


-- {{{ Volume widget type
local function worker(format, warg)
    if not warg then return end

    local mixer_state = {
        ["on"]  = "♫", -- "",
        ["off"] = "♩"  -- "M"
    }

    -- Get mixer control contents
    local f = io.popen("ossmix " .. warg)
    local mixer = f:read("*all")
    f:close()

    -- Capture mixer control state
    local volu = tonumber(string.match(mixer, "([%d]+)"))
    -- Handle mixers without data
    if volu == nil then
        return {0, mixer_state["off"]}
    end

    -- Handle mixers that are muted
    if string.find(mixer, "OFF") then
        mute = mixer_state["off"]
    else
        mute = mixer_state["on"]
    end

    return {volu, mute}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
