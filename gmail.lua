----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
----------------------------------------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local setmetatable = setmetatable
local helpers = require("vicious.helpers")
-- }}}


-- Gmail: provides count of new and subject of last e-mail in a Gmail inbox
module("vicious.gmail")


-- {{{ Gmail widget type
local function worker(format, login)
    -- Initialise tables
    local mail = {
        ["{count}"]   = "0",
        ["{subject}"] = "N/A"
    }

    -- Todo: find a safer way to do this
    local auth = login[1] .. ":" .. login[2]

    -- Get info from the Gmail atom feed
    local f = io.popen("curl --max-time 3 -fsu "..auth.." https://mail.google.com/mail/feed/atom")

    -- Could be huge don't read it all at once, info we are after is at the top
    for line in f:lines() do
        mail["{count}"] = line:match("<fullcount>([%d]+)</fullcount>") or mail["{count}"]

        -- Find subject tags
        local title = line:match("<title>(.*)</title>")
        -- If the subject changed then break out of the loop
        if title ~= nil and  --    Ignore the feed title
           title ~= "Gmail - Inbox for "..login[1].."@gmail.com" then
               -- Spam sanitize the subject
               title = helpers.escape(title)
               -- Don't abuse the wibox, truncate, then store
               mail["{subject}"] = helpers.truncate(title, 22)
               -- By this point we have the count, it comes before
               -- messages and always matches, at least 0
               break
        end
    end
    f:close()

    return mail
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
