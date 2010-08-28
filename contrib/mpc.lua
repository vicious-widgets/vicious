---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
--  * (c) 2009, Lucas de Vries <lucas@glacicle.com>
---------------------------------------------------

-- {{{ Grab environment
local type = type
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { find = string.find }
local helpers = require("vicious.helpers")
-- }}}


-- Mpc: provides the currently playing song in MPD
module("vicious.contrib.mpc")


-- {{{ MPC widget type
local function worker(format, warg)
    -- Get data from mpd
    local f = io.popen("mpc")
    local np = f:read("*line")
    f:close()

    -- Not installed,
    if np == nil or --  off         or                 stoppped.
       (string.find(np, "MPD_HOST") or string.find(np, "volume:"))
    then
        return {"Stopped"}
    end

    -- Check if we should scroll, or maybe truncate
    if warg then
        if type(warg) == "table" then
            np = helpers.scroll(np, warg[1], warg[2])
        else
            np = helpers.truncate(np, warg)
        end
    end

    return {helpers.escape(np)}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
