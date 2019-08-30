---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
--  * (c) 2009, Lucas de Vries <lucas@glacicle.com>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber

local helpers = require"vicious.helpers"
local spawn = require"vicious.spawn"
-- }}}

-- Mebibyte and gibibyte respectively, because backward compatibility
local UNIT = { mb = 1024, gb = 1024^2 }

-- FS: provides file system disk space usage
-- vicious.widgets.fs
return helpers.setasyncall{
    async = function(format, warg, callback)
        local fs_info = {} -- Get data from df
        spawn.with_line_callback_with_shell(
            warg and "LC_ALL=C df -kP" or "LC_ALL=C df -klP",
            { stdout = function (line)
                  -- (1024-blocks) (Used) (Available) (Capacity)% (Mounted on)
                  local s, u, a, p, m = line:match(
                     "^.-%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%%%s+([%p%w]+)")

                  if u and m then -- Handle 1st line and broken regexp
                      helpers.uformat(fs_info, m .. " size",  s, UNIT)
                      helpers.uformat(fs_info, m .. " used",  u, UNIT)
                      helpers.uformat(fs_info, m .. " avail", a, UNIT)

                      fs_info["{" .. m .. " used_p}"]  = tonumber(p)
                      fs_info["{" .. m .. " avail_p}"] = 100 - tonumber(p)
                  end
              end,
              output_done = function () callback(fs_info) end })
    end }
