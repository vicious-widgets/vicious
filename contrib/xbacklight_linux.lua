local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable

-- xbacklight: provides backlight level
-- vicious.contrib.xbacklight
local xbacklight = {}

local function xbacklight_cmd(args)
    local f = io.popen("xbacklight "..args)
    if f == nil then
      return nil
    else
      local line = f:read("*all")
      f:close()
      return line
    end
end

local function worker(format, warg)
    if not warg then warg = {} end
    if type(warg) ~= "table" then warg = { warg } end
    return { math.floor(tonumber(xbacklight_cmd(table.concat(warg, " ")))) }
end

return setmetatable(xbacklight, { __call = function(_, ...) return worker(...) end })
