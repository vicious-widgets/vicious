-- network status and usage widget type for GNU/Linux
-- Copyright (C) 2009  Lucas de Vries <lucas@glacicle.com>
-- Copyright (C) 2010  Adrian C. <anrxc@sysphere.org>
-- Copyright (C) 2017  mutlusun <mutlusun@github.com>
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
local os = { time = os.time }
local io = { lines = io.lines }
local string = { match = string.match }
local helpers = require("vicious.helpers")
-- }}}

-- Initialize function tables
local nets = {}
-- Variable definitions
local unit = { ["b"] = 1, ["kb"] = 1024,
    ["mb"] = 1024^2, ["gb"] = 1024^3
}

-- {{{ Net widget type
return helpers.setcall(function ()
    local args = {}

    -- Get NET stats
    for line in io.lines("/proc/net/dev") do
        -- Match wmaster0 as well as rt0 (multiple leading spaces)
        local name = string.match(line, "^[%s]?[%s]?[%s]?[%s]?([%w]+):")
        if name ~= nil then
            -- Received bytes, first value after the name
            local recv = tonumber(string.match(line, ":[%s]*([%d]+)"))
            -- Transmited bytes, 7 fields from end of the line
            local send = tonumber(string.match(line,
             "([%d]+)%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d$"))

            helpers.uformat(args, name .. " rx", recv, unit)
            helpers.uformat(args, name .. " tx", send, unit)

            -- Operational state and carrier detection
            local sysnet = helpers.pathtotable("/sys/class/net/" .. name)
            args["{"..name.." carrier}"] = tonumber(sysnet.carrier) or 0

            local now = os.time()
            if nets[name] == nil then
                -- Default values on the first run
                nets[name] = {}
                helpers.uformat(args, name .. " down", 0, unit)
                helpers.uformat(args, name .. " up",   0, unit)
            else -- Net stats are absolute, substract our last reading
                local interval = now - nets[name].time
                if interval <= 0 then interval = 1 end

                local down = (recv - nets[name][1]) / interval
                local up   = (send - nets[name][2]) / interval

                helpers.uformat(args, name .. " down", down, unit)
                helpers.uformat(args, name .. " up",   up,   unit)
            end

            nets[name].time = now

            -- Store totals
            nets[name][1] = recv
            nets[name][2] = send
        end
    end

    return args
end)
-- }}}
