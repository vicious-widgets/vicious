-- date and time widget type using os.date with optional time formatting
-- Copyright (C) 2009  Lucas de Vries <lucas@glacicle.com>
-- Copyright (C) 2010  Adrian C. <anrxc@sysphere.org>
-- Copyright (C) 2017  mutlusun <mutlusun@github.com>
-- Copyright (C) 2019  Nguyễn Gia Phong <vn.mcsinyx@gmail.com>
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
local os = { date = os.date, time = os.time }
local helpers = require"vicious.helpers"
-- }}}

return helpers.setcall(function (format, warg)
    return os.date(format or nil, warg and os.time()+warg or nil)
end)
