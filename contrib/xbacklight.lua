local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable

local helpers = require("vicious.helpers")


-- xbacklight: provides backlight level
-- vicious.contrib.xbacklight
local xbacklight = {}

local function parse(stdout, stderr, exitreason, exitcode)
    return math.floor(tonumber(stdout))
end

local function xbacklight_cmd()
    local f = io.popen("xbacklight")
    if f == nil then
      return nil
    else
      local line = f:read("*all")
      f:close()
      return line
    end
end

local function worker(format, warg)
    if warg == nil then warg = {}
    return math.floor(tonumber(xbacklight_cmd()))
end
-- }}}

return setmetatable(xbacklight, { __call = function(_, ...) return worker(...) end })
