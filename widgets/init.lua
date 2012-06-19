---------------------------------------------------
-- Vicious widgets for the awesome window manager
---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Setup environment
local setmetatable = setmetatable
local wrequire = require("vicious.helpers").wrequire

-- Vicious: widgets for the awesome window manager
-- vicious.widgets
local widgets = { _NAME = "vicious.widgets" }
-- }}}

-- Load modules at runtime as needed
return setmetatable(widgets, { __index = wrequire })
