-- contrib/ossvol_linux.lua
-- Copyright (C) 2010  Adrian C. <anrxc@sysphere.org>
-- Copyright (C) 2017  Jörg Thalheim <joerg@higgsboson.tk>
--
-- This file is part of Vicious.
--
-- Vicious is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as
-- published by the Free Software Foundation, either version 2 of the
-- License, or (at your option) any later version.
--
-- Vicious is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with Vicious.  If not, see <https://www.gnu.org/licenses/>.

-- {{{ Grab environment
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { match = string.match }
-- }}}


-- Ossvol: provides volume levels of requested OSS mixers
-- vicious.contrib.ossvol
local ossvol_linux = {}


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

return setmetatable(ossvol_linux, { __call = function(_, ...) return worker(...) end })
