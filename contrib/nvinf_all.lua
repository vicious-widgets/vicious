---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2015, Ziyuan Guo <s10e.cn@gmail.com>
---------------------------------------------------

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
