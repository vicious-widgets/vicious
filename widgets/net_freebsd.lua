-- network status and usage widget type for FreeBSD
-- Copyright (C) 2017,2019  mutlusun <mutlusun@github.com>
-- Copyright (C) 2019  Nguyễn Gia Phong <vn.mcsinyx@gmail.com>
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
local string = {
    match = string.match,
    gmatch = string.gmatch
}

local helpers = require("vicious.helpers")
local spawn = require("vicious.spawn")
-- }}}


-- Net: provides state and usage statistics of all network interfaces
-- vicious.widgets.net
local net_freebsd = {}


-- Initialize function tables
local nets = {}
-- Variable definitions
local unit = { ["b"] = 1, ["kb"] = 1024,
    ["mb"] = 1024^2, ["gb"] = 1024^3
}

-- {{{ Net widget type
local function parse(stdout, stderr, exitreason, exitcode)

    local args = {}
    local buffer = nil
    local now = os.time()

    for line in string.gmatch(stdout, "[^\n]+") do
        if not (line:find("<Link") or line:find("Name")) then -- skipping missleading lines
            local split = { line:match(("([^%s]*)%s*"):rep(12)) }

            if buffer == nil then
                buffer = { tonumber(split[8]), tonumber(split[11]) } -- recv (field 8) and send (field 11)
            else
                buffer = { buffer[1] + tonumber(split[8]),
                           buffer[2] + tonumber(split[11]) }
            end
        end
    end

    if buffer == nil then
        args["{carrier}"] = 0
        helpers.uformat(args, "rx", 0, unit)
        helpers.uformat(args, "tx", 0, unit)
        helpers.uformat(args, "down", 0, unit)
        helpers.uformat(args, "up",   0, unit)
    else
        args["{carrier}"] = 1
        helpers.uformat(args, "rx", buffer[1], unit)
        helpers.uformat(args, "tx", buffer[2], unit)

        if next(nets) == nil then
            helpers.uformat(args, "down", 0, unit)
            helpers.uformat(args, "up",   0, unit)
        else
            local interval = now - nets["time"]
            if interval <= 0 then interval = 1 end

            local down = (buffer[1] - nets[1]) / interval
            local up   = (buffer[2] - nets[2]) / interval

            helpers.uformat(args, "down", down, unit)
            helpers.uformat(args, "up",   up,   unit)
        end

        nets["time"] = now

        -- Store totals
        nets[1] = buffer[1]
        nets[2] = buffer[2]
    end

    return args

end

function net_freebsd.async(format, warg, callback)
    if not warg then return callback{} end
    spawn.easy_async("netstat -n -b -I " .. helpers.shellquote(warg),
                     function (...) callback(parse(...)) end)
end
-- }}}

return helpers.setasyncall(net_freebsd)
