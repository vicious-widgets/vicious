-- widget types initialization
-- Copyright (C) 2010  Adrian C. (anrxc) <anrxc@sysphere.org>
-- Copyright (C) 2011,2012  Jörg Thalheim <jthalheim@gmail.com>
-- Copyright (C) 2012  Arvydas Sidorenko <asido4@gmail.com>
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

local setmetatable = setmetatable
local wrequire = require((...):match(".*vicious") .. ".helpers").wrequire

return setmetatable({ _NAME = (...):match(".*vicious") .. ".widgets" }, { __index = wrequire })
