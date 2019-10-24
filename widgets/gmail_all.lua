-- new e-mails count and last e-mail subject on Gmail
-- Copyright (C) 2010  Adrian C. <anrxc@sysphere.org>
-- Copyright (C) 2017  mutlusun <mutlusun@github.com>
-- Copyright (C) 2017  starenka <starenka0@gmail.com>
-- Copyright (C) 2018-2019  Nguyễn Gia Phong <vn.mcsinyx@gmail.com>
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
local type = type
local tonumber = tonumber
local string = { match = string.match }

local helpers = require("vicious.helpers")
local spawn = require("vicious.spawn")
-- }}}

-- Gmail: provides count of new and subject of last e-mail on Gmail
-- vicious.widgets.gmail
local gmail_all = {}

-- {{{ Gmail widget type
local function parse(warg, stdout, stderr, exitreason, exitcode)
    local count =   -- Count comes before messages and matches at least 0
        tonumber(string.match(stdout, "<fullcount>([%d]+)</fullcount>")) or 0

    -- Find subject tag
    local title = string.match(stdout, "<entry>.-<title>(.-)</title>") or "N/A"

    -- Check if we should scroll, or maybe truncate
    if type(warg) == "number" then
        title = helpers.truncate(title, warg)
    elseif type(warg) == "table" then
        title = helpers.scroll(title, warg[1], warg[2])
    end

    return { ["{count}"] = count, ["{subject}"] = title }
end

function gmail_all.async(format, warg, callback)
    -- Get info from the Gmail atom feed using curl --netrc.
    -- With username 'user' and password 'pass'
    -- $HOME/.netrc should look similar to:
    -- machine mail.google.com login user password pass
    -- BE AWARE THAT MAKING THESE SETTINGS IS A SECURITY RISK!
    spawn.easy_async("curl -fsn https://mail.google.com/mail/feed/atom",
                     function (...) callback(parse(warg, ...)) end)
end
-- }}}

return helpers.setasyncall(gmail_all)
