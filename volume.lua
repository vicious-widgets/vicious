---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc.sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = {
    find = string.find,
    match = string.match
}
-- }}}


-- Volume: provides volume levels of requested ALSA mixers
module("vicious.volume")


-- {{{ Volume widget type
local function worker(format, channel)
    -- Get mixer data
    local f = io.popen("amixer get " .. channel)
    local mixer = f:read("*all")
    f:close()

    local volume_level = string.match(mixer, "([%d]?[%d]?[%d])%%")
    -- If muted return 0 (not "Mute") so we dont break progressbars
    if string.find(mixer, "%[off%]") or volume_level == nil then
        volume_level = 0
    end

    return {volume_level}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
