----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
----------------------------------------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { match = string.match }
-- }}}


-- Volume: provides volume levels of requested ALSA mixers
module("vicious.volume")


-- {{{ Volume widget type
local function worker(format, channel)
    -- Get mixer data
    local f = io.popen("amixer get " .. channel)
    local mixer = f:read("*all")
    f:close()

    -- Get volume level
    local volume_level = string.match(mixer, "([%d]?[%d]?[%d])%%")

    -- Don't break progressbars
    if volume_level == nil then
        return {0}
    end

    return {volume_level}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
