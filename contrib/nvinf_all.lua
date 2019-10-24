-- contrib/nvinf_all.lua
-- Copyright (C) 2015  Ziyuan Guo <s10e.cn@gmail.com>
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
local string = { gmatch = string.gmatch }
local setmetatable = setmetatable
local helpers = require("vicious.helpers")
-- }}}


-- vicious.widgets.nvinf
local nvinf_all = {}


-- {{{ NVIDIA infomation widget type
local function worker(format, warg)
    if not warg then warg = "0" end
    local nv_inf = {}
    local f = io.popen("LC_ALL=C nvidia-settings -q GPUUtilization -q [gpu:"..helpers.shellquote(warg).."]/GPUCoreTemp -q [gpu:"..helpers.shellquote(warg).."]/GPUCurrentClockFreqs -t")
    local all_info = f:read("*all")
    f:close()

    for num in string.gmatch(all_info, "%d+") do
        nv_inf[#nv_inf + 1] = tonumber(num)
    end

    return nv_inf
end
-- }}}

return setmetatable(nvinf_all, { __call = function(_, ...) return worker(...) end })
