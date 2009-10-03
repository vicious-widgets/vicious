---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc.sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local io = { open = io.open }
local setmetatable = setmetatable
local string = { gfind = string.gfind }
local helpers = require("vicious.helpers")
-- }}}


-- Mbox: provides the subject of last e-mail in a mbox file
module("vicious.mbox")


-- {{{ Mailbox widget type
local function worker(format, mbox)
    -- mbox could be huge, get a 15kb chunk from EOF
    --  * attachments could be much bigger than this
    local f = io.open(mbox)
    f:seek("end", -15360)
    local txt = f:read("*all")
    f:close()

    -- Find all Subject lines
    for s in string.gfind(txt, "Subject: ([^\n]*)") do subject = s end
    if subject then
        -- Spam sanitize only the last subject
        subject = helpers.escape(subject)

        -- Don't abuse the wibox, truncate
        subject = helpers.truncate(subject, 22)

        return {subject}
    else
        return {"N/A"}
    end
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
