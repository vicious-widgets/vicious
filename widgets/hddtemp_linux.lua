---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber

local helpers = require"vicious.helpers"
local spawn = require"vicious.spawn"
-- }}}


-- Hddtemp: provides hard drive temperatures using the hddtemp daemon
-- vicious.widgets.hddtemp
return helpers.setasyncall{
    async = function(format, warg, callback)
        if warg == nil then warg = 7634 end -- fallback to default hddtemp port
        local hdd_temp = {} -- get info from the hddtemp daemon
        spawn.with_line_callback_with_shell(
            "echo | curl -fs telnet://127.0.0.1:" .. warg,
            { stdout = function (line)
                  for d, t in line:gmatch"|([%/%w]+)|.-|(%d+)|[CF]|" do
                      hdd_temp["{"..d.."}"] = tonumber(t)
                  end
              end,
              output_done = function () callback(hdd_temp) end })
    end }
