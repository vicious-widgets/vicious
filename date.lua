----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
----------------------------------------------------------

-- {{{ Grab environment
local os = { date = os.date }
local setmetatable = setmetatable
-- }}}


-- Date: provides access to os.date with optional custom formatting
module("vicious.date")


-- {{{ Date widget type
local function worker(format)
    if format == nil then
        return os.date()
    else
        return os.date(format)
    end
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
