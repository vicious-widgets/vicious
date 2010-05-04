---------------------------------------------------
-- Licensed under the GNU General Public License v2
---------------------------------------------------
-- * (c) 2010, Jörg. T <jthalheim@mail.com>

-- {{{ Grab environment
local io = { popen = io.popen }
local setmetatable = setmetatable
-- }}}

-- Sum up: provides a number of files in several directories
-- @warg.paths a table with the paths which should be checked
-- @warg.pattern a global regex to match files (Default: match all)
-- use posix-egrep style instead of the default (less familar) emacs regex

-- Be carefull with directories, who contains a mass of files.
-- "find" is usally fast, but will also produce delays, if the inodes get to big. 
-- So if you want to count your music library, you may want to use locate/updatedb
module("vicious.widgets.sumup")


-- {{{ Sum up widget type
local function worker(format, warg)
	 if not warg then return end
   -- Initialise counter table
   local store = {}

   -- Match by default all files
   warg.pattern = warg.pattern or ".*"

	 -- Cycle through the given directories
   for i=1, #warg.paths do
      local f =  io.popen("find '"..warg.paths[i].."'"..
                          " -type f -regextype posix-egrep"..
                          " -regex '"..warg.pattern.."'")

      store[i] = 0
      for lines in f:lines() do
         store[i] = store[i] + 1
      end

      f:close()
   end
   return store 
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
