---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local type = type
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
local helpers = require("vicious.helpers")
local string = {
    match = string.match
}
-- }}}


-- Gmail: provides count of new and subject of last e-mail on Gmail
-- vicious.widgets.gmail
local gmail = {}


-- {{{ Variable definitions
local rss = {
  inbox   = "https://mail.google.com/mail/feed/atom",
  unread  = "https://mail.google.com/mail/feed/atom/unread",
  --labelname = "https://mail.google.com/mail/feed/atom/labelname",
}

-- Default is just Inbox
local feed = rss.inbox
local mail = {
    ["{count}"]   = 0,
    ["{subject}"] = "N/A"
}
-- }}}


-- {{{ Gmail widget type
local function worker(format, warg)
    -- Get info from the Gmail atom feed
    local f = io.popen("curl --connect-timeout 1 -m 3 -fsn " .. feed)

    -- Could be huge don't read it all at once, info we are after is at the top
    local xml = f:read(2000)

    if xml ~= nil then
        return mail
    end

    mail["{count}"] = -- Count comes before messages and matches at least 0
      tonumber(string.match(xml, "<fullcount>([%d]+)</fullcount>")) or mail["{count}"]

    -- Find subject tag
    local title = string.match(xml, "<entry>.-<title>(.-)</title>")

    if title ~= nil then
        -- Check if we should scroll, or maybe truncate
        if warg then
            if type(warg) == "table" then
                title = helpers.scroll(title, warg[1], warg[2])
            else
                title = helpers.truncate(title, warg)
            end
        end

        -- Spam sanitize the subject and store
        mail["{subject}"] = helpers.escape(title)
    end

    f:close()

    return mail
end
-- }}}

return setmetatable(gmail, { __call = function(_, ...) return worker(...) end })
