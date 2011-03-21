---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2011, Jörg T. <jthalheim@gmail.com>
---------------------------------------------------

-- {{{ Grab environment
local helpers_uformat = require("vicious.helpers").uformat
local io = { lines = io.lines }
local os = { time = os.time, difftime = os.difftime }
local pairs = pairs
local setmetatable = setmetatable
-- }}}


-- Disk I/O: provides I/O statistics for storage devices/partitions (only linux >= 2.6 )
module("vicious.widgets.dio")


-- Initialize function tables
local last_time = 0
local last_diskstats = {}
-- Constant definitions
local UNIT = {["s"] = 1, ["kb"] = 2, ["mb"] = 2048}

-- {{{ I/O widget type
local function read()
   local lines = {}
   for l in io.lines("/proc/diskstats") do
      -- linux kernel doc: Documentation/iostats.txt
      --   8       0 sda 5328 6084 205232 142076 1295 3162 35178 45946 0 58440 188000
      --             ^             ^                       ^
      local device, read, write = l:match("([^%s]+) %d+ %d+ (%d+) %d+ %d+ %d+ (%d+)")
      lines[device]={read, write}
   end
   return lines
end

local function worker(format)
   local diskstats = read()
   local diskusage = {}

   local time = os.time()
   local time_diff = os.difftime(time, last_time)

   -- should not happen since the minimum time difference in vicious is 1 sec
   if time_diff == 0 then time_diff = 1 end

   for device, stats in pairs(diskstats) do
	   -- ensure, we have last_diskstat to avoid insane values at the startup
	   local last_stats = last_diskstats[device] or stats

	   -- Check for overflows and counter resets (> 2^32)
	   if stats[1] < last_stats[1] or stats[2] < last_stats[2] then
		   last_stats[1], last_stats[2] = stats[1], stats[2]
	   end
	   -- Diskstats are absolute, so substract our last reading
	   -- dividing by timediff is needed cause we don't know how often the widget is called
	   local read  = (stats[1] - last_stats[1]) / time_diff
	   local write = (stats[2] - last_stats[2]) / time_diff

	   -- Calculate and store per disk I/O
	   helpers_uformat(diskusage, device.." read",  read,  UNIT)
	   helpers_uformat(diskusage, device.." write", write, UNIT)
	   helpers_uformat(diskusage, device.." total", read + write, UNIT)
   end

   last_time = time
   last_diskstats = diskstats
   return diskusage
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
