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
local function worker(format, channel)
    -- Get mixer data
    local f = io.popen("ossmix " .. channel)
    local mixer = f:read("*all")
    f:close()

    local vol = tonumber(string.match(mixer, "([%d]+)"))
    -- If mute return 0 (not "Mute") so we don't break progressbars
    if (vol == nil or vol == 0) or string.find(mixer, "OFF") then
        vol = 0
    end

    return {vol}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
