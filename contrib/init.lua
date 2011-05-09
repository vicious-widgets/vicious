---------------------------------------------------
-- Vicious widgets for the awesome window manager
---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------


local setmetatable = setmetatable
local require_once = require("vicious.helpers").require_once

-- Vicious: widgets for the awesome window manager
module("vicious.contrib")

-- Load modules at runtime as needed
setmetatable(_M,   {__index = require_once} )
