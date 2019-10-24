-- cmus music player widget type
-- Copyright (C) 2017  JuanKman94 <juan.carlos.menonita@gmail.com>
-- Copyright (C) 2017  Joerg Thalheim <joerg@thalheim.io>
-- Copyright (C) 2018-2019  Nguyễn Gia Phong <vn.mcsinyx@gmail.com>
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
local type = type
local tonumber = tonumber
local os = { getenv = os.getenv }

local helpers = require"vicious.helpers"
local spawn = require"vicious.spawn"
-- }}}

local CMUS_SOCKET = helpers.shellquote(os.getenv"CMUS_SOCKET")

-- Cmus: provides CMUS information
-- vicious.widgets.cmus
return helpers.setasyncall{
    async = function (format, warg, callback)
        local server = ""
        if type(warg) == "table" then
            server = " --server " .. helpers.shellquote(warg.host or warg[1])
        elseif CMUS_SOCKET ~= nil then
            server = " --server " .. CMUS_SOCKET
        end

        local cmus_state = { ["{duration}"] = 0, ["{file}"] = "N/A",
                             ["{status}"] = "N/A", ["{title}"] = "N/A",
                             ["{artist}"] = "N/A", ["{continue}"] = "off",
                             ["{shuffle}"] = "off", ["{repeat}"] = "off" }

        spawn.with_line_callback("cmus-remote --query" .. server, {
            stdout = function (line)
                for module, value in line:gmatch"([%w]+) (.*)$" do
                    if module == "file" or module == "status" then
                        cmus_state["{"..module.."}"] = value
                    elseif module == "duration" then
                        cmus_state["{"..module.."}"] = tonumber(value)
                    else
                        local k, v = value:gmatch("([%w]+) (.*)$")()
                        if module == "tag" then
                            cmus_state["{"..k.."}"] = v
                        elseif module == "set" and v == "true" then
                            cmus_state["{"..k.."}"] = "on"
                        end
                    end
                end
            end,
            output_done = function () callback(cmus_state) end })
    end }
