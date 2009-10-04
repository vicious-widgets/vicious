---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc.sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { match = string.match }
local helpers = require("vicious.helpers")
-- }}}


-- Gmail: provides count of new and subject of last e-mail on Gmail
module("vicious.gmail")


-- User data
local user = "" -- Todo:
local pass = "" --  * find a safer storage

-- {{{ Gmail widget type
local function worker(format, feed)
    local auth = user .. ":" .. pass
    local feed = feed or "https://mail.google.com/mail/feed/atom/unread"
    local mail = {
        ["{count}"]   = "0",
        ["{subject}"] = "N/A"
    }

    -- Get info from the Gmail atom feed
    local f = io.popen("curl --connect-timeout 1 -m 3 -fsu "..auth.." "..feed)

    -- Could be huge don't read it all at once, info we are after is at the top
    for line in f:lines() do
        mail["{count}"] = -- Count comes before messages and matches at least 0
          string.match(line, "<fullcount>([%d]+)</fullcount>") or mail["{count}"]

        -- Find subject tags
        local title = string.match(line, "<title>(.*)</title>")
        -- If the subject changed then break out of the loop
        if title ~= nil and  -- Todo: find a better way to deal with 1st title
           title ~= "Gmail - Label &#39;unread&#39; for "..user.."@gmail.com" then
               -- Spam sanitize the subject
               title = helpers.escape(title)
               -- Don't abuse the wibox, truncate, then store
               mail["{subject}"] = helpers.truncate(title, 22)
               break
        end
    end
    f:close()

    return mail
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
