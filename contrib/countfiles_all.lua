-- contrib/countfiles_all.lua
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
local io = { popen = io.popen }
local setmetatable = setmetatable
local pairs = pairs
-- }}}

-- countfiles: provides a number of files in several directories
-- @warg.paths a table with the paths which should be checked
-- @warg.pattern a global regex to match files (Default: match all)
-- use posix-egrep style instead of the default (less familiar) emacs regex

-- Be carefull with directories, who contains a mass of files.
-- "find" is usally fast, but will also produce delays, if the inodes get to big. 
-- So if you want to count your music library, you may want to use locate/updatedb instead.

-- vicious.contrib.countfiles
local countfiles_all = {}

-- {{{ Sum up widget type
local function worker(format, warg)
   if not warg then return end
   -- Initialise counter table
   local store = {}

   -- Match by default all files
   warg.pattern = warg.pattern or ".*"

   for key, value in pairs(warg.paths) do
      local f =  io.popen("find '"..value.."'"..
                          " -type f -regextype posix-egrep"..
                          " -regex '"..warg.pattern.."'")

      local lines = 0
      for line in f:lines() do
         lines = lines + 1
      end

      store[key] = (store[key] or 0) + lines

      f:close()
   end
   return store 
end
-- }}}

setmetatable(countfiles_all, { __call = function(_, ...) return worker(...) end })
