---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc.sysphere.org>
--  * (c) Wicked, Lucas de Vries
---------------------------------------------------

-- {{{ Grab environment
local os = { date = os.date }
local setmetatable = setmetatable
-- }}}


-- Date: provides access to os.date with optional custom formatting
module("vicious.date")


-- {{{ Date widget type
local function worker(format)
    return os.date(format or nil)
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
