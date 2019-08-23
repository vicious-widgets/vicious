---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
--  * (c) Maildir Biff Widget, Fredrik Ax
---------------------------------------------------

-- {{{ Grab environment
local type = type

local helpers = require"vicious.helpers"
local spawn = require"vicious.spawn"
-- }}}


-- Mdir: provides the number of new and unread messages in Maildir structures/dirs
-- vicious.widgets.mdir
local mdir_all = {}


-- {{{ Maildir widget type
function mdir_all.async(format, warg, callback)
    if type(warg) ~= "table" then return callback{} end
    local starting_points = ""
    for _,dir in ipairs(warg) do
        starting_points = starting_points .. " " .. helpers.shellquote(dir)
    end
    if starting_points == "" then return callback{ 0, 0 } end

    local new, cur = 0, 0
    spawn.with_line_callback(
        "find" .. starting_points .. " -type f -regex '.*/cur/.*2,[^S]*$';",
        { stdout = function (filename) cur = cur + 1 end,
          output_done = function ()
              spawn.with_line_callback(
                  "find" .. starting_points .. " -type f -path '*/new/*';",
                  { stdout = function (filename) new = new + 1 end,
                    output_done = function () callback{ new, cur } end })
          end })
end
-- }}}

return helpers.setasyncall(mdir_all)
